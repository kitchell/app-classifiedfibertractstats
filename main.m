function main()

switch getenv('ENV')
case 'IUHPC'
	disp('loading paths (HPC)')
	addpath(genpath('/N/u/hayashis/BigRed2/git/jsonlab'))
	addpath(genpath('/N/u/hayashis/BigRed2/git/afq-master'))
case 'VM'
	disp('loading paths (VM)')
	addpath(genpath('/usr/local/jsonlab'))
	addpath(genpath('/usr/local/afq-master'))
end

% load config.json
config = loadjson('config.json');

disp('config dump')
disp(config)

load(config.afq_fg);

tract_info = cell(length(fg_classified), 6);

for ifg=1:length(fg_classified)
    tractFibers = fg_classified(ifg);
    volVec=[];

    for istreamlines=1:length(tractFibers)
        streamLengths(istreamlines)=sum(sqrt(sum(diff(tractFibers{istreamlines},1,2).^2)));
        volVec=horzcat(volVec,tractFibers{istreamlines});
    end
    meanLength=mean(streamLengths);
    lengthSTDEV=std(streamLengths);
    count=length(streamLengths);
    %why doesn't it like totalLength?
    totalLength=sum(streamLengths);

    % volume, as indicated by number of 1mm voxels occupied by at least 1 tract
    % node.  In theory if you wanted to resample this computation (i.e. how
    % many .5 mm voxels are occpupied by at least 1 tract node) you could
    % just multiply the volVec by a factor.  I.e. .5mm -> 2 or .25 mm -> 4
    volume=length(unique(floor(volVec'),'rows'));

    tract_info{ifg,1} = fg_classified(ifg).name;
    tract_info{ifg,2} = count;
    tract_info{ifg,3} = meanLength;
    tract_info{ifg,4} = lengthSTDEV;
    tract_info{ifg,5} = totalLength;
    tract_info{ifg,6} = volume;

T = cell2table(tract_info);
T.Properties.VariableNames = {'Tracts', 'FiberCount', 'MeanLength',...
    'STDLength', 'TotalLength', 'Volume'};

writetable(T,'output_FiberStats.txt')

    
end