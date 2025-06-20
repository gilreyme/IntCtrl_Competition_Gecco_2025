%%
%clear classes
%py.importlib.invalidate_caches();

pyenv('Version',...
    'C:\Users\greyn\Documents\Control2025GECCO\interpretable-control-competition-main\ic39\Scripts\python.exe',...
    'ExecutionMode','OutOfProcess');
%%
terminate(pyenv)
pyenv('Version',...
    'C:\Users\greyn\Documents\Control2025GECCO\interpretable-control-competition-main\ic39\Scripts\python.exe',...
    'ExecutionMode','OutOfProcess');
%%
py.Meine_Toy_example.main()
%%
%py.importlib.import_module('Meine_Toy_example')
%py.importlib.import_module('example')
%py.importlib.import_module('controller')
py.Meine_Toy_example.main()
%terminate(pyenv)
%%