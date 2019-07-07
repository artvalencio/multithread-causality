function [cami_xy,cami_yx,mutual_info,diridx,te_xy,te_yx,pointwise]...
    = serialmultithreadcami(cause,effect,L_past,L_fut,cause_part,effect_part,tau,units,varargin)
% SERIALMULTITHREADCAMI Calculates the Causal Mutual Information (CaMI), Mutual Information,
% Transfer Entropy, Directionality Index and Pointwise Information Measures 
% when many parallel experiments are provided
%--------------------------------------------------------
%IF MULTITHREAD, WHY SERIAL???
%Because oftentimes computing in serial mode is faster than paralelizing,
%although the idea of perfoming the same calcs many individual experiments
%remains.
%--------------------------------------------------------
% Inputs:
%           cause,effect:  the time-series. Rows are values along time (no
%                  timestamp) and columns are each experiment.
%                  E.g., experiment 3 produced a cause and an effect. The 
%                  time-series of the cause is stored in column cause[:,3]
%                  and the associated effect on column effect[:,3].
%           L_past,L_fut: length of the symbolic sequence for analysis.
%                  (e.g.: L_past=3 L_fut=2: the analysis considers if 
%                   a historic of 3 points in the variables x and y is
%                   causally related to 2 points of the future of y).
%           cause_part,effect_part: vectors defining the position where the partition
%                  division lines are located. 
%                  (e.g.: x_part=[0.5,1] means that points of x<0.5 are 
%                  symbolic encoded as '0', between 0.5 and 1 are encoded 
%                  as '1', and x>1 are encoded as '2')
%           tau: time-delay of the time-Poincare mapping. If time-series is 
%                  already generated by a map, the user should set tau to 1. 
%                  Otherwise, for "continuous time-series" the user should find
%                  the tau leading to minimisation of cross correlation, or 
%                  maximal of mutual information or maximal of CaMI. This 
%                  strategy seeks to create a time-Poincare mapping that will 
%                  behave as a Markov system by the partition chosen (lx,ly).
%           units: 'bits' for log in base 2, 'nats' for log in base e. In
%                  case of typos, bits are assumed as standard.
%           varargin: options:
%               'save': to save the outputs to a file.
%               'delay', followed by value (integer): to add a delay between x and y.
%                        (e.g. delay,7: gives a delay of 7 time-series
%                        points between x and y, i.e., evaluates if x causes
%                        y considering that y might have delayed response of
%                        7 time units. Value can be negative too, for studies of
%                        phenomena similar to anticipated synchronization)
%               'local', followed by value (positive integer): to calulate measures 
%                        over a sliding rectangular window
%                        (e.g. 'local',10000: gives the measures calculated 
%                        over a sliding window of 10000 points) 
%--------------------------------------------------------
% Outputs:
%           cami_xy: Causal Mutual Information x -> y
%           cami_yx: Causal Mutual Information y -> x
%           mutual_info:      Mutual Information between x and y,
%                    calculated using symbolic sequences
%                    of length lx in variables x and y. 
%           diridx:  Directionality Index, defined as CaMI(x->y)-CaMI(y->x),
%                    positive if flow of information is x -> y
%           te_xy:   Transfer Entropy x -> y
%           te_yx:   Transfer Entropy y -> x
%
%           if 'save': 
%                  The file "calculations.mat" is generated containing
%                  all marginal and joint probabilities required for the
%                  calculation of CaMI. 
%                  The file "output.txt" is also generated containing a summary
%                  of all results.
%--------------------------------------------------------
% Examples:
%
%     (i)  Case on Bianco-Martinez, E. and Baptista, M.S. (arXiv:1612.05023):
%
%         [cami_xy,cami_yx,mi,diridx,te_xy,te_yx] = ...
%               serialmultithreadcami(x,y,2,3,0.5,0.5,1,'nats');
%
%           (In the paper x and y are single column time-series from coupled logistic maps, 
%            with r=4 and alpha=0.09. I suggest trying with more columns (parallel experiments),
%           and check if the causal link becomes more evident.)
%
%     (ii) A case with 3 initial divisions (not necessarily in same positions), 
%          2 points of past->2points of future, and high lag (tau=8):
%
%         [cami_xy,cami_yx,mi,diridx,te_xy,te_yx] = ...
%               serialmultithreadcami(x,y,2,2,[0.2,0.6],[0.2,0.8],8,'bits');
%
%--------------------------------------------------------
%(C) Dr Arthur Valencio[1,2]', Dr Norma Valencio[1,3]'' and Dr Murilo S. Baptista[1]
%[1] Institute for Complex Systems and Mathematical Biology (ICSMB), University of Aberdeen
%[2] Research, Innovation and Dissemination Center for Neuromathematics (RIDC NeuroMat)
%[3] Department of Environmental Sciences, Federal University of Sao Carlos (UFSCar)
%'Support: CNPq [206246/2014-5] and FAPESP [2018/09900-8], Brazil
%''Support: FAPESP [17/17224-0] and CNPq [310976/2017-0], Brazil
%This package is available as is, without any warranty. Use it at your own risk.
%--------------------------------------------------------
%Version update: 19 June 2018
%--------------------------------------------------------
%If useful please cite
%(1) Arthur Valencio. An information-theoretical approach to identify seismic precursors and earthquake-causing variables. PhD thesis, University of Aberdeen, 2018. Available at: http://digitool.abdn.ac.uk:1801/webclient/DeliveryManager?pid=237105&custom_att_2=simple_viewer
%(2) Arthur Valencio, Norma Valencio and Murilo S. Baptista. Multithread causality: causality toolbox for systems observed through many short parallel experiments. Open source codes for Matlab. 2018. Available at: https://github.com/artvalencio/multithread-causality/


%Below is the preamble. For the important parts, go to 'main' function.
    lx=L_past;
    ly=L_past+L_fut;

    %options
    print=0;
    delay=0;
    islocal=0;
    windowsize=0;
    if nargin>8
        for i=1:size(varargin)
                if strcmp(varargin{i},'save')
                    print=1;
                end
                if strcmp(varargin{i},'delay')
                    delay=varargin{i+1};
                end
                if strcmp(varargin{i},'local')
                    islocal=1;
                    windowsize=varargin{i+1};
                end
        end
    end

    %check input consistency
    if size(cause)~=size(effect)
        error('x and y must be of same size!')
    end
    if length(cause_part)~=length(effect_part)
        error('cause_part and effect_part must be of same size!')
    end
    ns=length(cause_part)+1; %partition resolution

    %adjusting if delayed option
    if delay~=0
        if delay>0
            effect=effect(1:length(cause(:,1))-delay,:);
            cause=cause(1:length(effect(:,1)),:);
        elseif delay<0
            cause=cause(1:length(effect(:,1))+delay);
            effect=effect(1:length(cause(:,1)));
        end
    end
       
    if islocal   %Calculates for sliding window case ('local' measures (in time))
        t=1;
        while 1
            xwindow=cause(t:t+windowsize,:);
            ywindow=effect(t:t+windowsize,:);
            [cami_xy(t),cami_yx(t),mutual_info(t),diridx(t),te_xy(t),te_yx(t),pointwise{t}] = main(xwindow,ywindow,lx,ly,cause_part,effect_part,tau,units,ns,print);
            if t+windowsize==length(cause(:,1))
                break;
            end
            t=t+1;
        end
    else %Calculation over the whole time-series ('global' measures)
        disp('Calculating')
        try
        fflush(stdout)
        catch
        end
        [cami_xy,cami_yx,mutual_info,diridx,te_xy,te_yx,pointwise] = main(cause,effect,lx,ly,cause_part,effect_part,tau,units,ns,print);
        disp('done')
    end
    
end

function [cami_xy,cami_yx,mutual_info,diridx,te_xy,te_yx,pointwise] = main(x,y,lx,ly,xpart,ypart,tau,units,ns,print)
    
    nnodes=length(x(1,:));
    tslen=length(x(:,1));
    xpartlen=length(xpart);
    ypartlen=length(ypart);
    %calculating symbols
    Sx(1:tslen,1:nnodes)=-1;
    Sy(1:tslen,1:nnodes)=-1;
    for node=1:nnodes
        for n=1:tslen %assign data points to partition symbols in x
            for i=1:xpartlen
                if x(n,node)<xpart(i)
                    Sx(n,node)=i-1;
                    break;
                end
            end
            if Sx(n,node)==-1
                Sx(n,node)=ns-1;
            end
        end
    end
    for node=1:nnodes
        for n=1:tslen %assign data points to partition symbols in y
            for i=1:ypartlen
                if y(n,node)<ypart(i)
                    Sy(n,node)=i-1;
                    break;
                end
            end
            if Sy(n,node)==-1
                Sy(n,node)=ns-1;
            end
        end
    end  
    
    [p_xp,p_yp,p_yf,p_ypf,p_xyp,p_xypf,phi_x,phi_yp,phi_yf]=getprobabilities(Sx,Sy,lx,ly,ns,tau,tslen,nnodes);
        
    %Calculating mutual information
    mutual_info=0;
    for i=1:ns^lx
        for j=1:ns^lx
            if (p_xp(i)*p_yp(j)>1e-14)&&(p_xyp(i,j)>1e-14)
                pmi(i,j)=p_xyp(i,j)*log(p_xyp(i,j)/(p_xp(i)*p_yp(j)));
                mutual_info=mutual_info+pmi(i,j);
            else
                pmi(i,j)=0;
            end
        end
    end
    
    %Calculating CaMI X->Y
    cami_xy=0;
    for i=1:ns^lx
        for j=1:ns^lx
            for k=1:1:ns^(ly-lx)
                if (p_xp(i)*p_ypf(j,k)>1e-14) && (p_xypf(i,j,k)>1e-14)
                    pcami_xy(i,j,k)=p_xypf(i,j,k)*log(p_xypf(i,j,k)/(p_xp(i)*p_ypf(j,k)));
                    cami_xy=cami_xy+pcami_xy(i,j,k);
                else
                    pcami_xy(i,j,k)=0;
                end
            end
        end
    end
    
    %Calculating CaMI Y->X
    [ip_x,ip_yp,ip_yf,ip_ypf,ip_xyp,ip_xypf,iphi_x,iphi_yp,iphi_yf]=getprobabilities(Sy,Sx,lx,ly,ns,tau,tslen,nnodes);
    cami_yx=0;
    for i=1:ns^lx
        for j=1:ns^lx
            for k=1:1:ns^(ly-lx)
                if (ip_x(i)*ip_ypf(j,k)>1e-14)&&(ip_xypf(i,j,k)>1e-14)
                    pcami_yx(i,j,k)=ip_xypf(i,j,k)*log(ip_xypf(i,j,k)/(ip_x(i)*ip_ypf(j,k)));
                    cami_yx=cami_yx+pcami_yx(i,j,k);
                else
                    pcami_yx(i,j,k)=0;
                end
            end
        end
    end
    
    %Adjusting units
    if strcmp(units,'nats')==0
        mutual_info=mutual_info/log(2);
        cami_xy=cami_xy/log(2);
        cami_yx=cami_yx/log(2);
        pmi=pmi/log(2);
        pcami_xy=pcami_xy/log(2);
        pcami_yx=pcami_yx/log(2);
    end

    %Obtaining remaining outputs
    diridx=cami_xy-cami_yx;
    te_xy=cami_xy-mutual_info;
    te_yx=cami_yx-mutual_info;
    
    %Generating struct of pointwise informational measures
    pointwise.pmi=pmi;
    pointwise.pcami_xy=pcami_xy;
    pointwise.pcami_yx=pcami_yx;
    pointwise.pdiridx=pcami_xy-pcami_yx;
    pointwise.pte_xy=pcami_xy-pmi;
    pointwise.pte_yx=pcami_yx-pmi;
    
    %print calculations to file
    if print
        timeseries=table;
        timeseries.x=x;
        timeseries.y=y;
        timeseries.Sx=Sx';
        timeseries.Sy=Sy';
        timeseries.phi_x=phi_x';
        timeseries.phi_yp=phi_yp';
        timeseries.phi_yf=phi_yf';
        timeseries.inv_phi_y=iphi_x';
        timeseries.inv_phi_xp=iphi_yp';
        timeseries.inv_phi_xf=iphi_yf';
        writetable(timeseries);
        dlmwrite('output.txt','CaMI calculation (multithread)','delimiter','');
        dlmwrite('output.txt','-----------------------------------','delimiter','','-append');
        dlmwrite('output.txt','Selected parameters by the user:','delimiter','','-append');
        dlmwrite('output.txt',strcat('- Number of symbols (ns): ',num2str(ns)),'delimiter','','-append');
        dlmwrite('output.txt',strcat('- Length of symbolic sequence in x (lx): ',num2str(lx)),'delimiter','','-append');
        dlmwrite('output.txt',strcat('- Length of symbolic sequence in y (ly): ',num2str(ly)),'delimiter','','-append');
        dlmwrite('output.txt','- Position of partition delimiter lines:','-append','delimiter','');
        dlmwrite('output.txt','* in x: ','-append','delimiter','');
        dlmwrite('output.txt',xpart,'delimiter','\t','precision',5,'-append')
        dlmwrite('output.txt','* in y: ','-append','delimiter','');
        dlmwrite('output.txt',ypart,'delimiter','\t','precision',5,'-append')
        dlmwrite('output.txt','-----------------------------------','delimiter','','-append');
        dlmwrite('output.txt','Output:','delimiter','','-append');
        dlmwrite('output.txt',strcat('- CaMI X->Y: ',num2str(cami_xy)),'delimiter','','-append');
        dlmwrite('output.txt',strcat('- CaMI Y->X: ',num2str(cami_yx)),'delimiter','','-append');
        dlmwrite('output.txt',strcat('- Directionality Index (CaMI_{X->Y} - CaMI_{Y->X}): ',num2str(diridx)),'delimiter','','-append');
        dlmwrite('output.txt',strcat('- Mutual Information of X and Y: ',num2str(mutual_info)),'delimiter','','-append');
        dlmwrite('output.txt',strcat('- Transfer Entropy X->Y: ',num2str(te_xy)),'delimiter','','-append');
        dlmwrite('output.txt',strcat('- Transfer Entropy Y->X: ',num2str(te_yx)),'delimiter','','-append');
        initialparameters=table;
        initialparameters.resolution=ns;
        initialparameters.symbol_x_length=lx;
        initialparameters.symbol_y_length=ly;
        save('calculations.mat','timeseries','initialparameters','cami_xy',...
            'cami_yx','diridx','mi','te_xy','te_yx','p_xp','p_yp','p_yf','p_ypf',...
            'p_xyp','p_xypf','ip_x','ip_yp','ip_yf','ip_ypf','ip_xyp','ip_xypf')
    end
end


function [p_xp,p_yp,p_yf,p_ypf,p_xyp,p_xypf,phi_x,phi_yp,phi_yf]=getprobabilities(Sx,Sy,lx,ly,ns,tau,tslen,nnodes)
% calculates the values of phi and probabilities used for CaMI and mutual information


    %initializing phi: removing points out-of-reach (start-end)
    phi_x(1:tau*lx,1:nnodes)=NaN;
    phi_yp(1:tau*lx,1:nnodes)=NaN;
    phi_yf(1:tau*lx,1:nnodes)=NaN;
    phi_x(tslen-tau*(ly-lx):tslen,1:nnodes)=NaN;
    phi_yp(tslen-tau*(ly-lx):tslen,1:nnodes)=NaN;
    phi_yf(tslen-tau*(ly-lx):tslen,1:nnodes)=NaN;
    %initializing probabilities of boxes
    p_xp(1:ns^lx+1)=0;
    p_yp(1:ns^lx+1)=0;
    p_yf(1:ns^(ly-lx)+1)=0;
    p_ypf(1:ns^lx+1,1:ns^(ly-lx)+1)=0;
    p_xyp(1:ns^lx+1,1:ns^lx+1)=0;
    p_xypf(1:ns^lx+1,1:ns^lx+1,1:1:ns^(ly-lx)+1)=0;
    %calculating phi_x, about the past of x
    for node=1:nnodes(1)
        for n=tau*lx+1:tslen-tau*(ly-lx)
            phi_x(n,node)=0;
            k=n-lx;%running index for sum over tau-spaced elements
            for i=n-tau*lx:tau:n-tau
                phi_x(n,node)=phi_x(n,node)+Sx(k,node)*ns^((n-1)-k);
                k=k+1;
            end
            p_xp(phi_x(n,node)+1)=p_xp(phi_x(n,node)+1)+1;
        end
    end
    p_xp=p_xp/sum(p_xp);
    %calculating phi_yp, about the past of y
    for node=1:nnodes
        for n=tau*lx+1:tslen-tau*(ly-lx)
            phi_yp(n,node)=0;
            k=n-lx;
            for i=n-tau*lx:tau:n-tau
                phi_yp(n,node)=phi_yp(n,node)+Sy(k,node)*ns^((n-1)-k);
                k=k+1;
            end
            p_yp(phi_yp(n,node)+1)=p_yp(phi_yp(n,node)+1)+1;
        end
    end
    p_yp=p_yp/sum(p_yp);
    %calculating phi_yf, about the future of y
    for node=1:nnodes
        for n=tau*lx+1:tslen-tau*(ly-lx)
            phi_yf(n,node)=0;
            k=n;
            for i=n:tau:n+tau*(ly-lx)-1
                phi_yf(n,node)=phi_yf(n,node)+Sy(k,node)*ns^((n+(ly-lx)-1)-k);
                k=k+1;
            end
            p_yf(phi_yf(n,node)+1)=p_yf(phi_yf(n,node)+1)+1;
        end
    end
    p_yf=p_yf/sum(p_yf);
    %calculating joint probabilities
    for node=1:nnodes
        for n=tau*lx+1:tslen-tau*(ly-lx)
            p_ypf(phi_yp(n,node)+1,phi_yf(n,node)+1)=p_ypf(phi_yp(n,node)+1,phi_yf(n,node)+1)+1;
            p_xyp(phi_x(n,node)+1,phi_yp(n,node)+1)=p_xyp(phi_x(n,node)+1,phi_yp(n,node)+1)+1;
            p_xypf(phi_x(n,node)+1,phi_yp(n,node)+1,phi_yf(n,node)+1)=p_xypf(phi_x(n,node)+1,phi_yp(n,node)+1,phi_yf(n,node)+1)+1;
        end
    end
    p_ypf=p_ypf/sum(sum(p_ypf));
    p_xyp=p_xyp/sum(sum(p_xyp));
    p_xypf=p_xypf/sum(sum(sum(p_xypf)));
end

function [cami_xy,mutual_info,te_xy] = calcconfidence(x,y,lx,ly,xpart,ypart,tau,units,ns)
    
    nnodes=length(x(1,:));
    tslen=length(x(:,1));
    xpartlen=length(xpart);
    ypartlen=length(ypart);
    %calculating symbols
    Sx(1:tslen,1:nnodes)=-1;
    Sy(1:tslen,1:nnodes)=-1;
    for node=1:nnodes
        for n=1:tslen %assign data points to partition symbols in x
            for i=1:xpartlen
                if x(n,node)<xpart(i)
                    Sx(n,node)=i-1;
                    break;
                end
            end
            if Sx(n,node)==-1
                Sx(n,node)=ns-1;
            end
        end
    end
    for node=1:nnodes
        for n=1:tslen %assign data points to partition symbols in y
            for i=1:ypartlen
                if y(n,node)<ypart(i)
                    Sy(n,node)=i-1;
                    break;
                end
            end
            if Sy(n,node)==-1
                Sy(n,node)=ns-1;
            end
        end
    end  
    
    [p_xp,p_yp,~,p_ypf,p_xyp,p_xypf]=getprobabilities(Sx,Sy,lx,ly,ns,tau,tslen,nnodes);
        
    %Calculating mutual information
    mutual_info=0;
    for i=1:ns^lx
        for j=1:ns^lx
            if (p_xp(i)*p_yp(j)>1e-14)&&(p_xyp(i,j)>1e-14)
                pmi(i,j)=p_xyp(i,j)*log(p_xyp(i,j)/(p_xp(i)*p_yp(j)));
                mutual_info=mutual_info+pmi(i,j);
            else
                pmi(i,j)=0;
            end
        end
    end
    
    %Calculating CaMI X->Y
    cami_xy=0;
    for i=1:ns^lx
        for j=1:ns^lx
            for k=1:1:ns^(ly-lx)
                if (p_xp(i)*p_ypf(j,k)>1e-14) && (p_xypf(i,j,k)>1e-14)
                    pcami_xy(i,j,k)=p_xypf(i,j,k)*log(p_xypf(i,j,k)/(p_xp(i)*p_ypf(j,k)));
                    cami_xy=cami_xy+pcami_xy(i,j,k);
                else
                    pcami_xy(i,j,k)=0;
                end
            end
        end
    end
        
    %Adjusting units
    if strcmp(units,'nats')==0
        mutual_info=mutual_info/log(2);
        cami_xy=cami_xy/log(2);
    end

    %Obtaining remaining outputs
    te_xy=cami_xy-mutual_info;

end

%print final part
function []=printbottom(errcami,errmutual_info,errte,maxrun)
    dlmwrite('output.txt','-----------------------------------','delimiter','','-append');
    dlmwrite('output.txt','Confidence margins:','delimiter','','-append');
    dlmwrite('output.txt',strcat('- Number of runs of random numbers (for confidence levels):', num2str(maxrun)),'delimiter','','-append');
    dlmwrite('output.txt',strcat('- CaMI: ',num2str(errcami)),'delimiter','','-append');
    dlmwrite('output.txt',strcat('- Mutual Information: ',num2str(errmutual_info)),'delimiter','','-append');
    dlmwrite('output.txt',strcat('- Transfer Entropy: ',num2str(errte)),'delimiter','','-append');
    dlmwrite('output.txt','-----------------------------------','delimiter','','-append');
    dlmwrite('output.txt','**Probability boxes and timeseries can be seen in calculations.mat**','delimiter','','-append');
    dlmwrite('output.txt','**Timeseries and box assignment can also be seen in timeseries.txt**','delimiter','','-append');
    dlmwrite('output.txt','-----------------------------------','delimiter','','-append');
    dlmwrite('output.txt','(C) Dr Arthur Valencio[1,2]*, Dr Norma Valencio[1,3]** and Dr Murilo S. Baptista[1]','delimiter','','-append');       
    dlmwrite('output.txt','[1] Institute for Complex Systems and Mathematical Biology (ICSMB), University of Aberdeen','delimiter','','-append');
    dlmwrite('output.txt','[2] Research, Innovation and Dissemination Center for Neuromathematics (RIDC NeuroMat)','delimiter','','-append');
    dlmwrite('output.txt','[3] Department of Environmental Sciences, Federal University of Sao Carlos (UFSCar)','delimiter','','-append');
    dlmwrite('output.txt','*Support: CNPq [206246/2014-5] and FAPESP [2018/09900-8], Brazil','delimiter','','-append');
    dlmwrite('output.txt','**Support: FAPESP [17/17224-0] and CNPq [310976/2017-0], Brazil','delimiter','','-append');
    dlmwrite('output.txt','-----------------------------------','delimiter','','-append');
    dlmwrite('output.txt','Version update: 18 June 2018','delimiter','','-append');
    dlmwrite('output.txt','-----------------------------------','delimiter','','-append');
    dlmwrite('output.txt','If useful, please cite:','delimiter','','-append');
    dlmwrite('output.txt','(1) Arthur Valencio. An information-theoretical approach to identify seismic precursors and earthquake-causing variables. PhD thesis, University of Aberdeen, 2018. Available at: http://digitool.abdn.ac.uk:1801/webclient/DeliveryManager?pid=237105&custom_att_2=simple_viewer','delimiter','','-append');
    dlmwrite('output.txt','(2) Arthur Valencio, Norma Valencio and Murilo S. Baptista. Multithread causality: causality toolbox for systems observed through many short parallel experiments. Open source codes for Matlab. 2018. Available at: https://github.com/artvalencio/multithread-causality/','delimiter','','-append');
end