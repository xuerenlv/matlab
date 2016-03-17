DATA_DIR = '../data/humanI/';
[test,station,Qnum,time,topic,artID,topicVal] = textread([DATA_DIR, 'articleData.csv'],'%d %s %d %d %s %d %s','delimiter', ',','headerlines',1);
% # some question: 1. these are all about article data?
% #                2. what about Qnum = 5,6,7,8?? they do not have topicVal?? Missing?
% #                3. # of articles with missing topicVal == # without missing??
% #                4. not all article has been repeated twice: such as 2249-- 4 times




%%% remove missing data
Nms = find(~strcmp(topicVal,'NA'));

topic = topic(Nms);
artID = artID(Nms);
topicVal = topicVal(Nms);
topicVal = char(topicVal) - 48;

artID_uniq = unique(artID);



%%%%% get train data  Xtrain, ytrain%%%
datadir = '../data/';
[R C V] = textread(strcat(datadir, 'nytwPhrase.csv'), '%d %d %d', 'delimiter', ',');
X = sparse( R, C, V );
[n,p] = size(X);
AllSamples = 1:n;
testSamples = artID_uniq;
TrainSamples = setdiff(AllSamples,artID_uniq);
Xtrain = X(TrainSamples,:);
%Xtest = X(testSamples,:);


%%%%%%%for each topic and each list %%%%%%%%%%
dictfile = 'nytwPhraseDict.csv';
[TopicWord] = importdata([datadir,'topiclist.csv']);
[words]= textread([datadir,dictfile], '%*d %s %*d %*d', 'delimiter', ',');
results_dir = '../results/Humanreduce/';
[RunID,queryID,wordID,word,weight] = textread(strcat(results_dir, 'reduce_results_full.csv'), '%d %d %d %s %f', 'delimiter', ',','headerlines',1);
[RunID_des,queryID_des,Query_lists,expanded,labeling,threshold,rescaling,kill_stops,fea_sel_methods,numPos,tuneParam,numdropped] = textread(strcat(results_dir, 'reduce_descript_full.csv'), '%d %d %s %d %s %d %d %d %s %d %f %d', 'delimiter', ',','headerlines',1);


%%% clear the content in ``result_file" and ``run_descript_file"
fid = fopen(['../results/Human/','Correlation','.csv'],'w');
fclose(fid);


% Header rows for the output files
save_to_file('../results/Human/','Correlation',  {'runid'}, {'qid'}, {'correlation'},{'correlation_uniq'}, .......
    {'TP'}, {'TN'}, {'FP'}, {'FN'}, {'precision'}, {'recall'}, {'F1'}, {'TP_uniq'}, {'TN_uniq'}, {'FP_uniq'}, {'FN_uniq'}, {'precision_uniq'}, {'recall_uniq'}, {'F1_uniq'},..........
    {'cond_num'},.............
    {'ave_eig'},............
    {'min_eig'},..............
    {'max_eig'},..............
    {'eig_80'},..........
    {'eig_90'},..........
    {'q80_eig'},...........
    {'q90_eig'},.........
    {'min_CNT'}, {'lst Q_CNT'}, {'median_CNT'}, {'3rd Q_CNT'}, {'max_CNT'});


for(runid = 1:max(RunID))
    for(qid = 1:max(queryID))
        index = (RunID == runid) & (queryID == qid);
        features = wordID(index); %% check if they are the right features.....

        index = (RunID_des == runid) & (queryID_des == qid);

        TPC = Query_lists(index);
        query = regexp( char( TopicWord(qid) ), ',', 'split' );

        lab = char(labeling(index));

        thre = threshold(index);

        [y, Xp] = calcResponse( Xtrain, query, ...
            'words', words, ...
            'labeling',lab, ...
            'rescaling', 0, ...
            'kill_stops', 0, ...
            'threshold', thre );

        Xt = full(Xp(:,features));



        y = (y + 1) /2 ;

        %%%%% fit logistic regression model %%%%%
        b= glmfit(Xt,[y ones(size(y))],'binomial','logit','const');

        %%%%% get the prediction score on test data%%%%%

        %%%%% get the correlation %%%%
        index = strcmp(topic, TPC);
        AID = artID(index);
        HTY = topicVal(index); %%% human varified True Y
        Xtest = X(AID,features);

        yfit = glmval(b,Xtest,'logit');



        AID_uniq = unique(AID);
        k = 0;
        HTY_uniq = [];
        yfit_uniq = [];
        for(aid = AID_uniq')
            k = k+1;
            indx = find(AID == aid);
            HTY_uniq(k) = mean(HTY(indx));
            yfit_uniq(k) = mean(yfit(indx));
        end

        cor = corr(HTY,yfit);

        cor_uniq = corr(HTY_uniq',yfit_uniq');

        
        HTY_bin = (HTY >= 4) * 1.0;
        yfit_bin = (yfit >= 0.5) * 1.0;
        
        TP = sum(HTY_bin == 1 & yfit_bin == 1)
        TN = sum(HTY_bin == 0 & yfit_bin == 0)
        FP = sum(HTY_bin == 0 & yfit_bin == 1)
        FN = sum(HTY_bin == 1 & yfit_bin == 0)
        if TP == 0
            precision = 0;
            recall = 0;
            F1 = 0;
        else
            precision = TP / (TP + FP)
            recall = TP /(TP + FN)
            F1 = 2*precision*recall / (precision + recall)
        end
        
        
        HTY_uniq_bin = (HTY_uniq >=4) * 1.0;
        yfit_uniq_bin = (yfit_uniq >= 0.5) * 1.0;
        
        TP_uniq = sum(HTY_uniq_bin == 1 & yfit_uniq_bin == 1)
        TN_uniq = sum(HTY_uniq_bin == 0 & yfit_uniq_bin == 0)
        FP_uniq = sum(HTY_uniq_bin == 0 & yfit_uniq_bin == 1)
        FN_uniq = sum(HTY_uniq_bin == 1 & yfit_uniq_bin == 0)
        if TP_uniq == 0
            precision_uniq = 0;
            recall_uniq = 0;
            F1_uniq = 0;
        else
            precision_uniq = TP_uniq / (TP_uniq + FP_uniq)
            recall_uniq = TP_uniq /(TP_uniq + FN_uniq)
            F1_uniq = 2*precision_uniq*recall_uniq / (precision_uniq + recall_uniq)
        end
        
        
        
        
        
        
        sub_X = X(:,features);
        eigen_value = eig(sub_X'*sub_X);



        cs = cumsum(eigen_value(end:-1:1)/sum(eigen_value));

        q80_eig = min(find(cs > 0.8))

        q90_eig = min(find(cs > 0.9))

        cond_num = eigen_value(end) / (eigen_value(1) + 0.0001);
        ave_eig = mean(eigen_value);
        min_eig = min(eigen_value);
        max_eig = max(eigen_value);
        eig_80 = eigen_value(q80_eig);
        eig_90 = eigen_value(q90_eig);
        
        
        %%%% see if a list contains very frequent words or very rare words

        [wdID,phrases,CNT,no_use] = textread([datadir,'nytwPhraseDict.csv'],'%d %s %d %d','delimiter', ',');
        clear wdID;
        clear phrases;
        clear no_use;


        count_list = CNT(features);        
        L = dataset(count_list);
        s = summary(L);
        su = s.Variables.Data.Quantiles;

        
        
        
        %%%%% store results in the following format: [topic, labeling, threshold, rescaling, feaSel, correlation]
        save_to_file('../results/Human/','Correlation', runid, qid, cor, cor_uniq, TP, TN, FP, FN, precision, recall, F1, TP_uniq, TN_uniq, FP_uniq, FN_uniq, precision_uniq, recall_uniq, F1_uniq,........
            cond_num, ......
            ave_eig,......
            min_eig,..........
            max_eig,..........
            eig_80,..........
            eig_90,.........
            q80_eig,..........
            q90_eig,...........
            su(1),...........
            su(2),............
            su(3),.........
            su(4),..........
            su(5));
    end
end


%%%%  Analyze the prediction scores %%%%%%%%%%%
