import keras
import h5py
import numpy as np
import matplotlib.pyplot as plt

def mean_absolute_percentage_error(y_true, y_pred):
    y_true, y_pred = np.array(y_true), np.array(y_pred)
    return np.mean(np.abs((y_true - y_pred) / y_true)) * 100

class traininghist(keras.callbacks.Callback):
    def __init__(self, test_data):
        self.test_data = test_data
        self.trainingloss = []
        self.trainingmape = []
    
    def on_epoch_end(self, epoch, logs={}):
        x, y = self.test_data
        loss, mape = self.model.evaluate(x, y, verbose=0)
        self.trainingloss.append(loss)
        self.trainingmape.append(mape)
        print('Training loss: {}, mape: {}\n'.format(loss, mape))

#Import training data

features1 = np.loadtxt('vec_mat_features_icex_src_0.01trainbb_800hz.csv',delimiter=",")
features2 = np.loadtxt('vec_mat_features_icex_src_0.01trainbb_810hz.csv',delimiter=",")
features3 = np.loadtxt('vec_mat_features_icex_src_0.01trainbb_820hz.csv',delimiter=",")
features4 = np.loadtxt('vec_mat_features_icex_src_0.01trainbb_830hz.csv',delimiter=",")
features5 = np.loadtxt('vec_mat_features_icex_src_0.01trainbb_840hz.csv',delimiter=",")
features6 = np.loadtxt('vec_mat_features_icex_src_0.01trainbb_850hz.csv',delimiter=",")
features7 = np.loadtxt('vec_mat_features_icex_src_0.01trainbb_860hz.csv',delimiter=",")
features8 = np.loadtxt('vec_mat_features_icex_src_0.01trainbb_870hz.csv',delimiter=",")
features9 = np.loadtxt('vec_mat_features_icex_src_0.01trainbb_880hz.csv',delimiter=",")
features10 = np.loadtxt('vec_mat_features_icex_src_0.01trainbb_890hz.csv',delimiter=",")
features11 = np.loadtxt('vec_mat_features_icex_src_0.01trainbb_900hz.csv',delimiter=",")
labels_unstand = np.loadtxt('vec_mat_rlabels_icex_src_0.01trainbb.csv',delimiter=",")
labels_t = []

features_mat = np.array([features1],[features2],[features3],[features4],[features5],[features6],[features7],[features8],[features9],[features10],[features11])

X_train = np.zeros((features.shape[0],32,32,22))

for f in range(len(features_mat)):
    features = features_mat[f]
    real = features[:,0::2]
    imag = features[:,1::2]

    for k in range(features.shape[0]):
        count = 0
        for i in range(32):
            for j in range(i,32):
                X_train[k,i,j,2*f] = real[k,count]
                X_train[k,i,j,2*f+1] = imag[k,count]
            
                if i!=j:
                    X_train[k,j,i,2*f] = X_train[k,i,j,2*f]
                    X_train[k,j,i,2*f+1] = -X_train[k,i,j,2*f+1]
            
                count = count + 1

#X_train[k,:,:,0] = X_train[k,:,:,0]/np.amax(np.abs(X_train[k,:,:,0]))
#X_train[k,:,:,1] = X_train[k,:,:,1]/np.amax(np.abs(X_train[k,:,:,1]))

labels_unstand = labels_unstand.ravel()
#y_train,mu,sigma_labels = std_y(labels_unstand)

y_train = labels_unstand

#Import test data

features_test1 = np.loadtxt('vec_mat_features_icex_src_test2bb_800hz.csv',delimiter=",")
features_test2 = np.loadtxt('vec_mat_features_icex_src_test2bb_810hz.csv',delimiter=",")
features_test3 = np.loadtxt('vec_mat_features_icex_src_test2bb_820hz.csv',delimiter=",")
features_test4 = np.loadtxt('vec_mat_features_icex_src_test2bb_830hz.csv',delimiter=",")
features_test5 = np.loadtxt('vec_mat_features_icex_src_test2bb_840hz.csv',delimiter=",")
features_test6 = np.loadtxt('vec_mat_features_icex_src_test2bb_850hz.csv',delimiter=",")
features_test7 = np.loadtxt('vec_mat_features_icex_src_test2bb_860hz.csv',delimiter=",")
features_test8 = np.loadtxt('vec_mat_features_icex_src_test2bb_870hz.csv',delimiter=",")
features_test9 = np.loadtxt('vec_mat_features_icex_src_test2bb_880hz.csv',delimiter=",")
features_test10 = np.loadtxt('vec_mat_features_icex_src_test2bb_890hz.csv',delimiter=",")
features_test11 = np.loadtxt('vec_mat_features_icex_src_test2bb_900hz.csv',delimiter=",")
temp_ytest = np.loadtxt('vec_mat_rlabels_icex_src_test2bb.csv',delimiter=",")
y_test= []

featurestest_mat = np.array([features_test1],[features_test2],[features_test3],[features_test4],[features_test5],[features_test6],[features_test7],[features_test8],[features_test9],[features_test10],[features_test11])

X_test = np.zeros((features_test.shape[0],32,32,2))

for f in range(len(featurestest_mat)):
    features_test = featurestest_mat[f]
    real_test = features_test[:,0::2]
    imag_test = features_test[:,1::2]

    for k in range(features_test.shape[0]):
        count = 0
        for i in range(32):
            for j in range(i,32):
                X_test[k,i,j,2*f] = real_test[k,count]
                X_test[k,i,j,2*f+1] = imag_test[k,count]
            
                if i!=j:
                    X_test[k,j,i,2*f] = X_test[k,i,j,2*f]
                    X_test[k,j,i,2*f+1] = -X_test[k,i,j,2*f+1]
            
                count = count + 1

#X_test[k,:,:,0] = X_test[k,:,:,0]/np.amax(np.abs(X_test[k,:,:,0]))
#X_test[k,:,:,1] = X_test[k,:,:,1]/np.amax(np.abs(X_test[k,:,:,1]))

temp_ytest = temp_ytest.ravel()
#y_test = (temp_ytest - mu)/sigma_labels
y_test = temp_ytest


print(X_train.shape)
print(y_train.shape)
print(X_test.shape)
print(y_test.shape)

#Training

index=np.arange(X_train.shape[0])
np.random.shuffle(index)

X_train=X_train[index,:,:,:]
y_train=y_train[index]

drate = 0.25
n_node = 256
batch_size = 128
loss='mean_squared_error'

model = keras.Sequential([
                          #keras.layers.Conv2D(input_shape=(32,32,2), filters=8, kernel_size=5,padding='same',activation='selu'),
                          #keras.layers.Dropout(0.5),
                          #keras.layers.BatchNormalization(),
                          keras.layers.Conv2D(input_shape=(32,32,22),filters=8, kernel_size=7,padding='same',activation='selu',strides=(2,2)),
                          keras.layers.BatchNormalization(),
                          #keras.layers.Dropout(0.5),
                          keras.layers.Conv2D(filters=16, kernel_size=5,padding='same',activation='selu',strides=(2,2)),
                          keras.layers.BatchNormalization(),
                          #keras.layers.Dropout(0.5),
                          keras.layers.Conv2D(filters=32, kernel_size=3,padding='same',activation='selu',strides=(2,2)),
                          keras.layers.BatchNormalization(),
                          #keras.layers.Dropout(0.5),
                          #keras.layers.Conv2D(filters=128, kernel_size=3,padding='same',activation='selu',strides=(2,2)),
                          #keras.layers.BatchNormalization(),
                          keras.layers.Flatten(),
                          keras.layers.Dense(units=n_node, activation='sigmoid'),
                          keras.layers.Dropout(drate),
                          keras.layers.Dense(units=1, activation='linear')])

lr = 0.001
optimizer = keras.optimizers.Adam(lr)

model.compile(optimizer,loss, metrics=['mape'])

filepath = "temp.h5"
checkpoint = keras.callbacks.ModelCheckpoint(filepath, monitor='val_loss', save_best_only=True, mode='auto',period=1)
reduce = keras.callbacks.ReduceLROnPlateau(monitor='val_loss', factor=0.1, patience=25, mode='auto')
early = keras.callbacks.EarlyStopping(monitor='val_loss', min_delta=1e-4, patience=50, mode='auto',restore_best_weights=True)
traininghistory = traininghist((X_train,y_train))
callbacks_list = [checkpoint,reduce,traininghistory,early]

infdb = model.fit(X_train, y_train, batch_size,verbose = True, epochs=2000, validation_split=0.2, shuffle=True,callbacks=callbacks_list)

#Testing

test_loss, test_acc = model.evaluate(X_test,y_test)
train_loss, train_acc = model.evaluate(X_train,y_train)

predictions = model.predict(X_test)
diff = abs((np.transpose(predictions))-(y_test))
error = diff[diff>1]
percent_correct = (len(y_test)-len(error))/len(y_test)

predictions_train = model.predict(X_train)
diff = abs((np.transpose(predictions_train))-(y_train))
error = diff[diff>1]
percent_correct_train = (len(y_train)-len(error))/len(y_train)

print('Training mape:', train_acc)
print('Test mape:', test_acc)
print('Training percent within 1km:',percent_correct_train*100)
print('Testing percent within 1km:', percent_correct*100)
