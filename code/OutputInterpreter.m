function OutputInterpreter(rootDir, relDir, test, tEnd, numberTest, m_range, etaSE_range, etaI_range)
        % Input: - rootDir: Absolute path to directory
        %        - relDir: Relative path to output directory
        %        - test: Light test or full test
        %        - tEnd: Total number of days of the simulation
        %        - numberTest: Number of trials
        %        - m_range: Values of m (fit)
        %        - etaSE_range: Values of etaSE (fit)
        %        - etaI_range: Values of etaI (fit)
        %
        % Reads output files contained in folder OutputEbola. Creates graph
        % of cumulative number of cases for light test.
    
    %% 1. Light test    
    if(strcmp(test,'LightTest'))
        Data_Aug2018 = load('Data_Aug2018.mat');
        filePattern = fullfile(rootDir, relDir,'Data_LightTest*.txt');
        theFiles = dir(filePattern);
        Cases = zeros(tEnd+1, 7, numberTest); 
        
        for iFile = 1:length(theFiles)
            % Extract data
            Data = importdata(strcat('OutputEbola/', theFiles(iFile).name));
            Cases(:,:,iFile) = Data.data(:,3:9);
        end
        meanCases = reshape(mean(Cases,3),tEnd+1,7);
        
        set(groot,'DefaultTextInterpreter','LaTex');
        set(groot,'DefaultLegendInterpreter','LaTex');
        figure('Renderer', 'painters', 'Position', [300 100 1000 650])
        hold on
        c=get(gca,'colororder');
        plot((0:tEnd)', meanCases(:,1),'Color', c(1,:))        
        plot((0:tEnd)', meanCases(:,2),'Color', c(2,:))        
        plot((0:tEnd)', meanCases(:,3),'Color', c(3,:))
        plot((0:tEnd)', meanCases(:,4),'Color', c(4,:))
        plot((0:tEnd)', meanCases(:,5),'Color', c(5,:))
        plot((0:tEnd)', meanCases(:,6),'k')
        plot((0:tEnd)', meanCases(:,7),'b')
        plot((1:tEnd)', Data_Aug2018.Data(:,2), 'b--')
        plot((1:tEnd)', Data_Aug2018.Data(:,3), 'k--')
        xlabel('Time [days]')
        ylabel('Population [unit]')
        title('Evolution of Ebola infection over time')
        legend('Exposed', 'Infected', 'Hospitalized', 'Buried', 'Recovered', 'Safely buried', 'Cumulative cases','Infected Data','Death Data','Location','Best')
        set(gca, 'Ticklabelinterpreter', 'LaTex', 'FontSize', 16)
    end
    
    %% 2. Full test
    if(strcmp(test,'Comparison'))
        Data_May2018 = load('Data_May2018.mat');
        filePattern = fullfile(rootDir, relDir,'Data_TestComp*.txt');
        theFiles = dir(filePattern);
        Cases = zeros(tEnd+1, 7, numberTest); 
        
        for iFile = 1:length(theFiles)
            % Extract data
            Data = importdata(strcat('OutputEbola/', theFiles(iFile).name));
            Cases(:,:,iFile) = Data.data(:,3:9);
        end
        meanCases = reshape(mean(Cases,3),tEnd+1,7);
        
        set(groot,'DefaultTextInterpreter','LaTex');
        set(groot,'DefaultLegendInterpreter','LaTex');
        figure('Renderer', 'painters', 'Position', [300 100 1000 650])
        hold on
        c=get(gca,'colororder');
        plot((0:tEnd)', meanCases(:,1),'Color', c(1,:))        
        plot((0:tEnd)', meanCases(:,2),'Color', c(2,:))        
        plot((0:tEnd)', meanCases(:,3),'Color', c(3,:))
        plot((0:tEnd)', meanCases(:,4),'Color', c(4,:))
        plot((0:tEnd)', meanCases(:,5),'Color', c(5,:))
        plot((0:tEnd)', meanCases(:,6),'k')
        plot((0:tEnd)', meanCases(:,7),'b')
        plot((1:tEnd)', Data_May2018.Data(:,2), 'b--')
        plot((1:tEnd)', Data_May2018.Data(:,3), 'k--')
        xlabel('Time [days]')
        ylabel('Population [unit]')
        title('Evolution of Ebola infection over time')
        axis([0 80 0 110])
        legend('Exposed', 'Infected', 'Hospitalized', 'Buried', 'Recovered', 'Safely buried', 'Cumulative cases','Infected Data','Death Data','Location','Best')
        set(gca, 'Ticklabelinterpreter', 'LaTex', 'FontSize', 16)      
    end
    
    if(strcmp(test,'FullTest'))
        Data_Aug2018 = load('Data_Aug2018.mat');
        MeanCount = zeros(length(m_range),length(etaSE_range),length(etaI_range),tEnd+1,9);
        J = zeros(length(m_range),length(etaSE_range),length(etaI_range));   % Function to minimize

        for im = 1:length(m_range)
            for iSE = 1:length(etaSE_range)
                for iI = 1:length(etaI_range)
                    filePattern = fullfile(rootDir, relDir, strcat(['data_m' num2str(m_range(im)) '_SE' num2str(etaSE_range(iSE)) '_I' num2str(etaI_range(iI)) '*.txt'])); 
                    theFiles = dir(filePattern);

                    % Extract data
                    Count = zeros(tEnd+1,9,numberTest);
                    for iFile = 1:numberTest
                        data = importdata(strcat('OutputEbola/', theFiles(iFile).name));
                        Count(:,:,iFile) = data.data;
                    end
                    MeanCount(im,iSE,iI,:,:) = mean(Count,3);
                end
            end
        end
        
        for im = 1:length(m_range)
            for iSE = 1:length(etaSE_range)
                for iI = 1:length(etaI_range)
                    computedCases = reshape(MeanCount(im,iSE,iI,:,9), 1, tEnd+1);
                    computedDeath = reshape(MeanCount(im,iSE,iI,:,8), 1, tEnd+1);
                    if ((im == 3) && (iSE == 3) && (iI == 1))
                        figure
                        hold on
                        plot((1:tEnd)', computedCases(2:end)','b')
                        plot((1:tEnd)', Data_Aug2018.Data(:,2), 'b--')
                        plot((1:tEnd)', computedDeath(2:end)','k')
                        plot((1:tEnd)', Data_Aug2018.Data(:,3), 'k--')
                        title(strcat(['m = ' num2str(m_range(im)) ',SE = ' num2str(etaSE_range(iSE)) ',I = ' num2str(etaI_range(iI))]))
                    end
                    J(im,iSE,iI) = (1/(tEnd+1))*(sum((Data_Aug2018.Data(:,2) - computedCases(2:end)').^2) ...
                                              + sum((Data_Aug2018.Data(:,3) - computedDeath(2:end)').^2));
                end
            end
        end
        [indA,indB] = find(J == min(J(:)),1);
        resultsIndex(1) = fix(indB/length(etaI_range)) + 1;
        resultsIndex(2) = indA;
        if (mod(indB,length(etaI_range)) == 0)
            resultsIndex(3) = length(etaI_range);
            resultsIndex(1) = resultsIndex(1) - 1;
        else
            resultsIndex(3) = mod(indB,length(etaI_range));
        end
        save('J.mat','J')
        Parameters = [m_range(resultsIndex(2)) etaSE_range(resultsIndex(3)) etaI_range(resultsIndex(1))];
        disp(strcat(['m = ' num2str(Parameters(1))]))
        disp(strcat(['etaSE = ' num2str(Parameters(2))]))
        disp(strcat(['etaI = ' num2str(Parameters(3))]))
    end
end
