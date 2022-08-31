## Combined_Model_and_shap

import sys
for pth in sys.path:
    print(pth)
modulename = 'lifelines'
if modulename not in sys.modules:
    import sys
    print('Following imported')
    import pprint
    print('pprint')
    import tensorflow as tf
    from tensorflow.keras import regularizers
    print('tensorflow')
    import keras as k
    print('keras')
    import matplotlib.pyplot as plt
    print('matplotlib')
    import numpy as np
    print('numpy')
    import pandas as pd
    print('pandas')
    import os
    print('os')
    import shap
    print('shap')
    from sklearn.model_selection import train_test_split
    print('sklearn, train_test_split')
    from keras.models import Sequential
    from keras.layers import Dense, Dropout, Activation, Flatten, Input, concatenate,Conv2D,AveragePooling2D,MaxPool2D
    from keras.backend import dropout 
    print('keras - Sequential, Dense, Dropout, Activation, Flatten, Input, dropout')
    import lifelines
    print('lifelines')
    import pickle 
    print('pickle')

def loss_lik_efron(y_true,y_pred):
  time = y_true[:,0]
  #time = tf.cast(time,'float32')
  event = y_true[:,1]#.astype('float32')

  y_pred= k.backend.flatten(y_pred)
  y_pred=tf.cast(y_pred,tf.float32)

  n = tf.shape(time)[0]
  sort_index=tf.nn.top_k(time,k=n,sorted=True).indices

  time = k.backend.gather(reference=time,indices = sort_index)
  event = k.backend.gather(reference=event,indices = sort_index)  
  y_pred = k.backend.gather(reference=y_pred,indices = sort_index)  

  time_event = time * event
  unique_ftime = tf.unique(tf.boolean_mask(tensor = time_event, mask = tf.greater(time_event, 0))).y
  m = tf.shape(unique_ftime)[0]
  tie_count=tf.unique_with_counts(tf.boolean_mask(time_event, tf.greater(time_event, 0))).count
  ind_matrix = k.backend.expand_dims(time,0) - k.backend.expand_dims(time,1)
  ind_matrix = k.backend.equal(x=ind_matrix,y=k.backend.zeros_like(ind_matrix))
  #print(tf.unique_with_counts(time).count)

  time_count = k.backend.cumsum(tf.unique_with_counts(time).count)
  time_count = k.backend.cast(time_count - k.backend.ones_like(time_count), dtype = tf.int32)
  ind_matrix = k.backend.gather(ind_matrix, time_count)
  ind_matrix=tf.cast(ind_matrix,'float32')


  event=tf.cast(event,'float32')
  tie_haz = k.backend.exp(y_pred) * event
  tie_haz = k.backend.dot(ind_matrix, k.backend.expand_dims(tie_haz))
  event_index = tf.math.not_equal(tie_haz,0)
  tie_haz = tf.boolean_mask(tie_haz, event_index)

  tie_risk = y_pred * event
  tie_risk = k.backend.dot(ind_matrix, k.backend.expand_dims(tie_risk))
  tie_risk = tf.boolean_mask(tie_risk, event_index)

  cum_haz = k.backend.dot(ind_matrix, k.backend.expand_dims(k.backend.exp(y_pred)))
  cum_haz = k.backend.reverse(tf.cumsum(k.backend.reverse(cum_haz, axes = 1)), axes = 1)
  cum_haz = tf.boolean_mask(cum_haz, event_index)


  #import pdb; #pdb.set_trace()
  #pdb.set_trace()
  global likelihood

  if likelihood is None:
    likelihood = tf.Variable(0., trainable = False) 

  j = tf.cast(0, dtype = tf.int32)
  def loop_cond(j,a,b,c,d,e):
    return j < m

  def loop_body(j, tc, tr, th, ch, lik):
    #pdb.set_trace()
    l = tc[j]
    l = k.backend.cast(l, dtype = tf.float32)
    J = tf.linspace(start = tf.cast(0, tf.float32), stop = l-1, num = tf.cast(l, tf.int32))/l 
    Dm = ch[j] - J*th[j]
    lik = lik + tr[j] - tf.math.reduce_sum(tf.math.log(Dm))
    one = k.backend.ones_like(j)
    j_new = j + one
    return(list([j_new, tc, tr, th, ch, lik]))
  #loop_cond = function(j, ...) {return(j < m)}

  loop_out = tf.while_loop(cond = loop_cond, body = loop_body,
                            loop_vars = list([j, tie_count, tie_risk, tie_haz, cum_haz, likelihood]))
  log_lik = loop_out[-1]

  return(tf.negative(log_lik))
likelihood = None

def load_data(name_study):
     #for either sherlock og own computer..
    try: #for sherlock
        Path_Indecies_train=(os.getcwd() + '/' + 'Combined' + '/Labels/indices_train.csv')
        Path_Indecies_test=(os.getcwd() + '/' + 'Combined' + '/Labels/indices_test.csv')
        path_cens_lab = (os.getcwd() + '/' + 'Combined' + '/Labels/Comb_cens.txt')

        index_train=pd.read_csv(Path_Indecies_train,header=None)
        index_test=pd.read_csv(Path_Indecies_test,header=None)
        cens_lab = pd.read_csv(path_cens_lab)
        
        cens_lab = cens_lab[["days", "isdead"]]
            
        features=pd.read_csv( os.getcwd() + '/' + 'Combined' + '/Data' + '/Combined_'+ name_study +'.txt')
    except: #for computer
        Path_Indecies_train=(os.getcwd() + '\\' + 'Combined' + '\\Labels\\indices_train.csv')
        Path_Indecies_test=(os.getcwd() + '\\' + 'Combined' + '\\Labels\\indices_test.csv')
        path_cens_lab = (os.getcwd() + '\\' + 'Combined' + '\\Labels\\Comb_cens.txt')

        index_train=pd.read_csv(Path_Indecies_train,header=None)
        index_test=pd.read_csv(Path_Indecies_test,header=None)
        cens_lab = pd.read_csv(path_cens_lab)
        
        cens_lab = cens_lab[["days", "isdead"]]
            
        features=pd.read_csv( os.getcwd() + '\\' + 'Combined' + '\\Data' + '\\Combined_' +name_study + '.txt')
    #features = features.drop(features.columns[[range(round(np.shape(features)[1]/2),np.shape(features)[1])]],axis = 1)
    ###

    np.random.seed(53702)
    randnums= np.random.randint(0,10000,len(cens_lab))/10000
    features["RandomArray"]=randnums

    ### 
    print(np.shape(features))

    rows_with_nan = [index for index, row in features.iterrows() if row.isnull().any()]

    print(str(len(rows_with_nan)) + ' removed for having nans as features')

    features=features.drop(axis=0, index=rows_with_nan)

    #features_EOG_R
    #features_EEG
    #features_ECG
    #features_EMG

    cens_lab=cens_lab.drop(axis=0,index=rows_with_nan)

    Rem_more = [index for index, row in cens_lab.iterrows() if row.isnull().any()]

    print(str(len(Rem_more)) + ' removed for having empty censoring label')

    features=features.drop(axis=0, index=Rem_more)

    cens_lab=cens_lab.drop(axis=0,index=Rem_more)

    cens_lab=cens_lab.astype(int)
    ###
    #features_EOG_R
    #features_EEG
    #features_ECG
    #features_EMG
    np = features.to_numpy()

    np_cens=cens_lab.to_numpy()

    nptrainidx=index_train.to_numpy().astype(int);
    nptestidx=index_test.to_numpy().astype(int);

    x_train = np[nptrainidx,:]

    y_train_tmp=np_cens[nptrainidx,:]

    x_test = np[nptestidx,:]

    y_test_tmp=np_cens[nptestidx,:]

    x_train=x_train.reshape(np.shape(x_train)[0],np.shape(x_train)[2])

    y_train=y_train_tmp.reshape(np.shape(y_train_tmp)[0],np.shape(y_train_tmp)[2])

    x_test=x_test.reshape(np.shape(x_test)[0],np.shape(x_test)[2])

    y_test=y_test_tmp.reshape(np.shape(y_test_tmp)[0],np.shape(y_test_tmp)[2])

    comb_train=np.concatenate([x_train],axis=1)
    comb_test=np.concatenate([x_test],axis=1)

    feature_names=list(features.columns)
    print(np.shape(comb_train))
    shapes=[0,x_test.shape[1]]

    return comb_train,comb_test,feature_names,shapes,y_train,y_test

def Init_Model(comb_train,shapes,num_L1,num_lr,dropOut):
    
    model = Sequential()

    #model.build(input_shape=125)
    model.add(Dense(512, 
                    activation='selu',
                    kernel_regularizer=regularizers.L1(num_L1)))
    model.add(Dropout(0.2))

    model.add(Dense(128, 
                    activation='selu',
                    kernel_regularizer=regularizers.L1(num_L1)))
    model.add(Dropout(0.2))

    model.add(Dense(64, 
            activation='selu',
            kernel_regularizer=regularizers.L1(num_L1)))
    model.add(Dropout(0.2))

    model.add(Dense(34, 
            activation='selu',
            kernel_regularizer=regularizers.L1(num_L1)))
    model.add(Dropout(0.2))

    model.add(Dense(1, 
                    activation='selu'))

    model.compile(loss=loss_lik_efron,
                  optimizer=tf.keras.optimizers.Adam(num_lr),#tf.keras.optimizers.RMSprop(num_lr),#'adam',
                    metrics=None)
    return model

def Run_Model(Min_CI,L1s,Lrs,batch_sizes,comb_train,comb_test,feature_names,shapes,model,y_train,y_test):
  #hyperparameters
  modelnumber=0
  print("Model:" + str(modelnumber) + "_BS:" + str(batch_sizes) + "_LR:" + str(Lrs) + "_L1:" + str(L1s))
  num_L1=L1s
  num_lr=Lrs
  num_epoch=200
  batch_size=batch_sizes
  
  callback = tf.keras.callbacks.EarlyStopping(monitor='loss', patience=10)

  history=model.fit(x=comb_train, y=y_train, 
              batch_size=batch_size, 
              epochs=num_epoch,  ################CHANGE MEEE
              verbose=1, 
              validation_split=0.1,
              callbacks=[callback])
  
  predicts=model.predict(comb_test)
  df = pd.DataFrame(y_test, columns=['T', 'E'])
  df["predicts"]=predicts
  if bool(abs(pd.isnull(df["predicts"][1])-1)):
    try:
      cph = lifelines.fitters.coxph_fitter.CoxPHFitter().fit(df, 'T', 'E')
      cindex=round(lifelines.utils.concordance_index(df['T'], -cph.predict_partial_hazard(df), df['E'])*100,1)

      print(cindex)

      plt.plot(history.history['loss'])
      plt.plot(history.history['val_loss'])

      modelnumber += 1
      modelname="Model:" + str(modelnumber) + "_BS:" + str(batch_sizes) + "_LR:" + str(Lrs) + "_L1:" + str(L1s) + "_CI:" + str(cindex)
      TitleName="Model loss DNNSurv - BS:" + str(batch_sizes) + "_LR:" + str(Lrs) + "_L1:" + str(L1s) + "_CI:" + str(cindex)
      plt.title(TitleName)
      plt.ylabel('loss')
      plt.xlabel('epoch')
      plt.legend(['train', 'test'], loc='upper left')
      plt.show()
      plt.savefig(name_study + '_' + modelname + ".png", bbox_inches='tight')
      #plt.clf()
    except Exception as e:
      print(e) 
      cindex=0
  else: 
      print('predict contains nans')
      cindex=0  
  return model,cindex

def run_shap(model,x_train,x_test,feature_names,name_study):
  explainer = shap.Explainer(model.predict, x_train,max_evals=15000,feature_names=feature_names)
  shap_values = explainer(x_test)
  #print(shap_values)
  NumPat=np.shape(shap_values.values)[0]
  matrix= np.zeros((NumPat, len(feature_names)))
  #explainer = shap.Explainer(model.predict, x_train,max_evals=2513,feature_names=features.columns.tolist())
  for i in range(NumPat):
    print(i)
    matrix[i,:]=shap_values.values[i]
    
  np.savetxt("matrix_combined_"+name_study + ".csv", matrix, delimiter=",")
  with open('Shap_Vals_combined_' + name_study + '.pkl', 'wb') as outp:
    pickle.dump(shap_values, outp, pickle.HIGHEST_PROTOCOL)

  
  np.savetxt("feature_names" + name_study+ ".csv", feature_names, delimiter=",")
  shap.plots.beeswarm(shap_values,max_display=15)
  shap.plots.bar(shap_values.abs.mean(0))

def main(Min_CI,comb_train,comb_test,feature_names,shapes,y_train,y_test,name_study):
  #hyperparameters
  L1s=0.001#[0.1,0.01,0.005,0.001,0.0005,0.0001]
  Lrs=0.001#[0.0005]#[1,0.1,0.01,0.005,0.001,0.0005,0.0001]
  batch_sizes=512#[32,64,128,256,512,1024]
  modelnumber=0
  dropOut=0.6

  for i in range(1):
    print('Iteration: ' + str(i+1))
    cindex=0
    while cindex < Min_CI:
        modelnumber+=1
        print(modelnumber)
        model=Init_Model(comb_train,shapes,L1s,Lrs,dropOut)
        #plot_model(model, to_file='multiple_inputs.png',show_shapes=True)
        model,cindex=Run_Model(Min_CI,L1s,Lrs,batch_sizes,comb_train,comb_test,feature_names,shapes,model,y_train,y_test)
        
        run_shap(model,comb_train,comb_test,feature_names,name_study)


  #plot_model(model, to_file='multiple_inputs.png',show_shapes=True)
  return model
if __name__ == '__main__':

    name_study='EEG'

    if True:
      print('Loading Data...')
      comb_train,comb_test,feature_names,shapes,y_train,y_test=load_data(name_study)
      print('Loading Data Completed')
    
    Min_CI=62.5
    model=main(Min_CI,comb_train,comb_test,feature_names,shapes,y_train,y_test,name_study)