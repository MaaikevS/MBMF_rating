%% Correlation rating and stay behaviour
%     load('Fit_implicit22.mat')
%     load('Fit_explicit28.mat')

    f2 = figure;
    axes1 = subplot(1,2,1);
    hold(axes1,'on');
    
    ha(1) = scatter(Exp_output.MB,Exp_output.MBrating,'k', 'filled');
    linearCoefficients = polyfit(Exp_output.MB,Exp_output.MBrating, 1);
    xFit = linspace(-1, 1, 20);
    yFit = polyval(linearCoefficients, xFit);
    plot(xFit, yFit, 'k-', 'LineWidth', 1);

    ha(2) = scatter(Imp_output.MB,Imp_output.MBrating,'k');
    linearCoefficients = polyfit(Imp_output.MB,Imp_output.MBrating, 1);
    xFit = linspace(-1, 1, 20);
    yFit = polyval(linearCoefficients, xFit);
    plot(xFit, yFit, 'k--', 'LineWidth', 1);
    legend(ha,'Explicit', 'Implicit', 'Location', 'NorthWest')

    xlabel('MB choice')
    ylabel('MB rating')
    title('Model-based behaviour')
    
    axes2 = subplot(1,2,2);
    hold(axes2,'on');
    
    scatter(Exp_output.MF,Exp_output.MFrating,'k', 'filled')
    linearCoefficients = polyfit(Exp_output.MF,Exp_output.MFrating, 1);
    xFit = linspace(-1, 1, 20);
    yFit = polyval(linearCoefficients, xFit);
    plot(xFit, yFit, 'k-', 'LineWidth', 1);

    scatter(Imp_output.MF,Imp_output.MFrating,'k')
    linearCoefficients = polyfit(Imp_output.MF,Imp_output.MFrating, 1);
    xFit = linspace(-1, 1, 20);
    yFit = polyval(linearCoefficients, xFit);
    plot(xFit, yFit, 'k--', 'LineWidth', 1);
    
    xlabel('MF choice')
    ylabel('MF rating')
    title('Model-free behaviour')

    set(f2,'units','centimeter','position',[1,5,15,7])
