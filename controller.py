import numpy as np
import cv2
from gymnasium import Space
from gymnasium.core import ActType
import os
import csv


class Controller:

    def control(self, observation: np.ndarray) -> np.ndarray:
        raise NotImplementedError


class RandomController(Controller):
     #print(f"No Obs: {observation.shape}, dtype: {observation.dtype}, max: {observation.max()}, min: {observation.min()}")

    def __init__(self, action_space: Space[ActType]) -> None:
        self.action_space = action_space

    def control(self, observation: np.ndarray) -> np.ndarray:
        print(f"Obs shape: {observation.shape}, dtype: {observation.dtype}, max: {observation.max()}, min: {observation.min()}")
        return self.action_space.sample()

class PIDAController:

    def __init__(self, action_space: Space[ActType]) -> None:
        self.action_space = action_space

        # Control gains
        self.Kp = 0.05
        self.Ki = 0.0
        self.Kd = 0.0
        self.Ka = 0.0

        if os.path.exists("pid_params.csv"):
            with open("pid_params.csv", mode="r") as file:
                reader = csv.DictReader(file)
                for row in reader:
                    self.Kp = float(row["Kp"])
                    self.Ki = float(row["Ki"])
                    self.Kd = float(row["Kd"])
                    self.Ka = float(row["Ka"])
                    #print(f" Kp: {self.Kp}")
                    break  # solo una línea esperada

        # Internal states
        self.integral = 0
        self.prev_error = 0
        self.prev_derivative = 0
        self.last_paddle_y = 100
        self.frame_count = 0

    def control(self, observation: np.ndarray) -> int:
        self.frame_count += 1

        # Convert to grayscale
        gray = cv2.cvtColor(observation, cv2.COLOR_RGB2GRAY)
        display = cv2.cvtColor(gray, cv2.COLOR_GRAY2BGR)  # For drawing in color

        # --- Detect Ball ---
        _, ball_thresh = cv2.threshold(gray, 200, 255, cv2.THRESH_BINARY)
        contours, _ = cv2.findContours(ball_thresh, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)

        ball_y = None
        for cnt in contours:
            x, y, w, h = cv2.boundingRect(cnt)
            if 2 <= w <= 6 and 2 <= h <= 6:
                ball_y = y + h // 2
                cv2.rectangle(display, (x, y), (x+w, y+h), (0, 0, 255), 1)  # Red
                cv2.circle(display, (80, ball_y), 4, (0, 0, 255), -1)  # Red dot
                break

        # --- Detect Paddle ---
        paddle_region = gray[:, 130:150]
        _, paddle_thresh = cv2.threshold(paddle_region, 128, 255, cv2.THRESH_BINARY)
        paddle_contours, _ = cv2.findContours(paddle_thresh, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)

        paddle_y = None
        for cnt in paddle_contours:
            x, y, w, h = cv2.boundingRect(cnt)
            if h > 10 and w <= 4:
                paddle_y = y + h // 2
                self.last_paddle_y = paddle_y
                break

        if paddle_y is None:
            paddle_y = self.last_paddle_y

        # Draw blue circle for paddle
        cv2.circle(display, (140, paddle_y), 4, (255, 0, 0), -1)

        # --- Control Logic ---
        if ball_y is not None:
            error = ball_y - paddle_y
            self.integral += error
            derivative = error - self.prev_error
            acc = derivative - self.prev_derivative

            u = (self.Kp * error + self.Ki * self.integral +
                 self.Kd * derivative + self.Ka * acc)

            self.prev_error = error
            self.prev_derivative = derivative

            # Decision logic with saturation near bounds
            if abs(error) < 4 or paddle_y <= 5 or paddle_y >= 205:
                action = 0
            elif u > 0:
                action = 5
            else:
                action = 2
        else:
            action = 0

        # --- Debug Info ---
        #print(f"[Frame {self.frame_count}] Ball_Y: {ball_y}, Paddle_Y: {paddle_y}, "
        #      f"Error: {ball_y - paddle_y if ball_y is not None else 'N/A'}, Action: {action}")

        # --- Visualization ---
        #cv2.imshow("PIDA Debug View", display)
        #cv2.waitKey(1)  # 1 ms delay to render properly

        return action
