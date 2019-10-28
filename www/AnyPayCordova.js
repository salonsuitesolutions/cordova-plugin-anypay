var exec = require('cordova/exec');

var refTransaction = null;

exports.AnyPayTransaction = function() {
    this.type = null;
    this.totalAmount = null;
    this.subtotal = null;
    this.tax = null;
    this.currency = null;
    this.tip = null;
    this.cardExpiryMonth = null;
    this.cardExpiryYear = null;
    this.maskedPAN = null;
    this.cardholderName = null;
    this.CVV2 = null;
    this.address = null;
    this.postalCode = null;
    this.cardNumber = null;
    this.cardInterfaceModes = ['SWIPE', 'TAP', 'INSERT', 'PINPAD'];
    this.approvedStatus = null;
    this.externalId = null;
    this.internalId = null;
    this.signature = null;
};

exports.coolMethod = function (arg0, success, error) {
    exec(success, error, 'AnyPayCordova', 'coolMethod', [arg0]);
};

exports.initializeSDK = function (success, error) {
    exec(success, error, 'AnyPayCordova', 'initializeSDK', []);
};

exports.authenticateWorldnetTerminal = function (arg0, arg1, arg2, success, error) {
    exec(success, error, 'AnyPayCordova', 'authenticateWorldnetTerminal', [arg0, arg1, arg2]);
};

exports.connectToBluetoothReader = function (success, error) {
    exec(success, error, 'AnyPayCordova', 'connectToBluetoothReader', []);
};

exports.connectAudioReader = function (success, error) {
    exec(success, error, 'AnyPayCordova', 'connectAudioReader', []);
};

exports.startEMVSale = function (arg0, arg1, success, error) {
    exec(success, error, 'AnyPayCordova', 'startEMVSale', [arg0, arg1]);
};

exports.startKeyedSale = function (arg0, arg1, success, error) {
    exec(success, error, 'AnyPayCordova', 'startKeyedSale', [arg0, arg1]);
};

exports.subscribeOnCardReaderConnected = function (success, error) {
    exec(success, error, 'AnyPayCordova', 'subscribeOnCardReaderConnected', []);
};

exports.subscribeOnCardReaderDisconnected = function (success, error) {
    exec(success, error, 'AnyPayCordova', 'subscribeOnCardReaderDisconnected', []);
};

exports.subscribeOnCardReaderConnectFailed = function (success, error) {
    exec(success, error, 'AnyPayCordova', 'subscribeOnCardReaderConnectFailed', []);
};

exports.subscribeOnCardReaderError = function (success, error) {
    exec(success, error, 'AnyPayCordova', 'subscribeOnCardReaderError', []);
};

exports.disconnectReader = function (success, error) {
    exec(success, error, 'AnyPayCordova', 'disconnectReader', []);
};

exports.AnyPayTransaction.prototype.execute = function (successCallback, errorCallback, readerEventCallback) {

    refTransaction = this;

    responseCallback = function (response) {

        if (response.hasOwnProperty('internalId'))
            refTransaction.internalId = response.internalId;

        if (response.hasOwnProperty('externalId'))
            refTransaction.externalId = response.externalId;

        if (response.hasOwnProperty('internalID'))
            refTransaction.internalId = response.internalID;

        if (response.hasOwnProperty('externalID'))
            refTransaction.externalId = response.externalID;

        refTransaction.approvedStatus = response.approved;

        successCallback(response);
    };

    if (readerEventCallback === undefined)
        exec(responseCallback, errorCallback, 'AnyPayCordova', 'startKeyedTransaction', [this]);
    else {
        exec(readerEventCallback, null, 'AnyPayCordova', 'subscribeToCardReaderEvent', []);
        exec(responseCallback, errorCallback, 'AnyPayCordova', 'startEMVSale', [this]);
    }
};

exports.AnyPayTransaction.prototype.setOnSignatureRequired = function (successCallback, errorCallback) {
    exec(successCallback, errorCallback, 'AnyPayCordova', 'setOnSignatureRequired', []);
};


exports.AnyPayTransaction.prototype.proceed = function (successCallback, errorCallback) {
    exec(successCallback, errorCallback, 'AnyPayCordova', 'proceed', [this.signature]);

};

exports.AnyPayTransaction.prototype.updateSignature = function (arg0, successCallback, errorCallback) {
    this.signature = arg0;
    exec(successCallback, errorCallback, 'AnyPayCordova', 'updateSignature', [this.signature]);

};

exports.AnyPayTransaction.prototype.adjustTip = function (arg0, successCallback, errorCallback) {
    exec(successCallback, errorCallback, 'AnyPayCordova', 'adjustTip', [arg0]);
};

exports.AnyPayTransaction.prototype.sendReceipt = function (arg0, successCallback, errorCallback) {
    this.signature = arg0;
    exec(successCallback, errorCallback, 'AnyPayCordova', 'sendReceipt', [this.signature]);

};

exports.fetchTransactions = function (arg0, arg1, successCallback, errorCallback) {
    if ((arg1 === null) || (arg1 === undefined))
        arg1 = '';

    exec(successCallback, errorCallback, 'AnyPayCordova', 'fetchTransactions', [arg0, arg1]);
};
