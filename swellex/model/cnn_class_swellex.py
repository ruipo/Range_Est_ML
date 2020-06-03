
import keras
import h5py
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

def encode(series):
    return pd.get_dummies(series.astype(str))

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
        print('Training loss: {}, acc: {}\n'.format(loss, mape))


#Import training data

features = np.loadtxt('vec_mat_features_icex_src_0.01train.csv',delimiter=",")
temp_labels = np.loadtxt('vec_mat_clabels_icex_src_0.01train.csv',delimiter=",")
labels_t = []

real = features[:,0::2]
imag = features[:,1::2]
X_train = np.zeros((features.shape[0],21,21,2))

for k in range(features.shape[0]):
    count = 0
    for i in range(21):
        for j in range(i,21):
            X_train[k,i,j,0] = real[k,count]
            X_train[k,i,j,1] = imag[k,count]
            
            if i!=j:
                X_train[k,j,i,0] = X_train[k,i,j,0]
                X_train[k,j,i,1] = -X_train[k,i,j,1]
            
            count = count + 1

#X_train[k,:,:,0] = X_train[k,:,:,0]/np.amax(np.abs(X_train[k,:,:,0]))
#X_train[k,:,:,1] = X_train[k,:,:,1]/np.amax(np.abs(X_train[k,:,:,1]))


for l in range(len(temp_labels)):
    labels_t.append(str(temp_labels[l]))

labels_t = np.array(labels_t)
labels_t = labels_t.ravel()

def encode(series):
    return pd.get_dummies(series.astype(str))

y_train = encode(labels_t)
labels = list(y_train.columns.values)

y_train = pd.DataFrame.as_matrix(y_train)

#Import test data
features_test = np.loadtxt('vec_mat_features_icex_src_test2.csv',delimiter=",")
temp_ytest = np.loadtxt('vec_mat_clabels_icex_src_test2.csv',delimiter=",")
y_test= []

real_test = features_test[:,0::2]
imag_test = features_test[:,1::2]
X_test = np.zeros((features_test.shape[0],21,21,2))

for k in range(features_test.shape[0]):
    count = 0
    for i in range(21):
        for j in range(i,21):
            X_test[k,i,j,0] = real_test[k,count]
            X_test[k,i,j,1] = imag_test[k,count]
            
            if i!=j:
                X_test[k,j,i,0] = X_test[k,i,j,0]
                X_test[k,j,i,1] = -X_test[k,i,j,1]
            
            count = count + 1

#X_test[k,:,:,0] = X_test[k,:,:,0]/np.amax(np.abs(X_test[k,:,:,0]))
#X_test[k,:,:,1] = X_test[k,:,:,1]/np.amax(np.abs(X_test[k,:,:,1]))


for l in range(len(temp_ytest)):
    y_test.append(str(temp_ytest[l]))

y_test = np.array(y_test)
y_test = y_test.ravel()
label_test = y_test.ravel()

y_test = encode(y_test)
y_test = pd.DataFrame.as_matrix(y_test)

print(X_train.shape)
print(y_train.shape)
print(X_test.shape)
print(y_test.shape)

#Training

index=np.arange(X_train.shape[0])
np.random.shuffle(index)

X_train=X_train[index,:,:,:]
y_train=y_train[index,:]

drate = 0.25
n_node = 256
batch_size = 128
loss='categorical_crossentropy'

model = keras.Sequential([
                          keras.layers.Conv2D(input_shape=(21,21,2), filters=16, kernel_size=3,padding='same',activation='selu',strides=(2,2)),
                          keras.layers.BatchNormalization(),
                          keras.layers.Dropout(0.5),
                          keras.layers.Conv2D(filters=128, kernel_size=5,padding='same',activation='selu',strides=(2,2)),
                          keras.layers.BatchNormalization(),
                          keras.layers.Dropout(0.5),
                          keras.layers.Conv2D(filters=256, kernel_size=5,padding='same',activation='selu',strides=(2,2)),
                          keras.layers.BatchNormalization(),
                          keras.layers.Dropout(0.5),
                          #keras.layers.Conv2D(filters=32, kernel_size=3,padding='same',activation='selu',strides=(2,2)),
                          #keras.layers.BatchNormalization(),
                          #keras.layers.Dropout(0.5),
                          #keras.layers.Conv2D(filters=128, kernel_size=3,padding='same',activation='selu',strides=(2,2)),
                          #keras.layers.BatchNormalization(),
                          keras.layers.Flatten(),
                          keras.layers.Dense(units=n_node, activation='selu'),
                          keras.layers.Dropout(drate),
                          keras.layers.Dense(units=101, activation='softmax')])

lr = 0.001
optimizer = keras.optimizers.Adam(lr)

model.compile(optimizer,loss, metrics=['accuracy'])

filepath = "temp.h5"
checkpoint = keras.callbacks.ModelCheckpoint(filepath, monitor='val_loss', save_best_only=True, mode='auto',period=1)
reduce = keras.callbacks.ReduceLROnPlateau(monitor='val_loss', factor=0.1, patience=75, mode='auto')
early = keras.callbacks.EarlyStopping(monitor='val_loss', min_delta=1e-4, patience=125, mode='auto',restore_best_weights=True)
traininghistory = traininghist((X_train,y_train))
callbacks_list = [checkpoint,reduce,traininghistory,early]

infdb = model.fit(X_train, y_train, batch_size,verbose = True, epochs=5000, validation_split=0.2, shuffle=True,callbacks=callbacks_list)

#Testing

test_loss, test_acc = model.evaluate(X_test,y_test)
train_loss, train_acc = model.evaluate(X_train,y_train)

print('Test accuracy:', test_acc)
print('Training accuracy:', train_acc)

predictions = model.predict(X_test)

pred_labels = []
for i in np.argmax(predictions, axis=1):
    pred_labels.append(labels[i])
