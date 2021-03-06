cfg = coder.config('exe');
cfg.CustomSource = 'mainTx.cpp';
cfg.CustomInclude = 'sourcefiles/cpp/';
cfg.TargetLang='C++';
cfg.PostCodeGenCommand = 'setbuildargs(buildInfo)';
functionsToThread = {'Transmitter'};
additionalSourceFiles = {};
outputFunctionName = {'TX'};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Do Not Edit Below
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Run Codegen, if earlier than 2014, must add include paths manually for
% sdru

tic;

Release = ver;Release = Release.Release;
Release = str2double(Release(3:6));
if Release > 2013
    codegen('-config','cfg',functionsToThread{:},additionalSourceFiles{:},'-o',outputFunctionName{:});
else
    hostname = lower(gethostname);
    hostname = hostname(2:end);
    setenv('SDRU_DEPLOYMENT_HOSTNAME', hostname);
    sdruPath = sdruroot;
    sandboxRoot = fullfile(matlabroot, 'toolbox', 'shared', 'sdr', 'sdru');
    isSandboxRun = strcmp(sdruPath, sandboxRoot);
    
    % Use install paths
    incPath = fullfile(sdruPath, 'include');
    libPathPre = sdruPath;
    
    % extern/include must come before src/include
    includeDir = [fullfile(matlabroot, 'extern', 'include') ' ' ...
        fullfile(matlabroot, 'src', 'include') ' ' incPath];
    if isempty(cfg.CustomInclude)
        cfg.CustomInclude = includeDir;
    else
        cfg.CustomInclude = [cfg.CustomInclude ' ' includeDir];
    end
    
    arch = computer('arch');
    switch (arch)
        case {'glnxa64', 'glnx86'}
            libpath = fullfile(libPathPre, 'bin', arch);
            libname = 'libmwusrp_uhd_capi.so';
        case {'win32','win64'}
            libpath = fullfile(libPathPre, 'lib', arch);
            libname = 'libmwusrp_uhd_capi.lib';
        case {'maci64'}
            libpath = fullfile(libPathPre, 'bin', arch);
            libname = 'libmwusrp_uhd_capi.dylib';
        otherwise
            error(message('sdru:compilesdru:UnsupportedPlatform'));
    end
    if isempty(cfg.CustomLibrary)
        cfg.CustomLibrary = fullfile(libpath, libname);
    else
        cfg.CustomLibrary = [cfg.CustomLibrary ' ' fullfile(libpath, libname)];
    end
    
    
    if (cfg.InlineThreshold ~= 10) && (cfg.InlineThreshold < 200)
        warning(message('sdru:compilesdru:InlineThreshold'))
    end
    cfg.InlineThreshold = 200;
    
    if (cfg.InlineThresholdMax ~= 200) && (cfg.InlineThreshold < 400)
        warning(message('sdru:compilesdru:InlineThresholdMax'))
    end
    cfg.InlineThresholdMax = 400;
    
    % Pass the rest of the arguments to codegen
    codegenResult = codegen(functionsToThread{:},additionalSourceFiles{:},'-config','cfg','-o',outputFunctionName{:});
end

total = toc;
fprintf('Build duration: %f (Seconds)\n',total);


