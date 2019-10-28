package com.anywherecommerce.anypaycordova;

import com.anywherecommerce.android.sdk.GenericEventListener;
import com.anywherecommerce.android.sdk.GenericEventListenerWithParam;
import com.anywherecommerce.android.sdk.Logger;
import com.anywherecommerce.android.sdk.MeaningfulError;
import com.anywherecommerce.android.sdk.MeaningfulErrorListener;
import com.anywherecommerce.android.sdk.MeaningfulMessage;
import com.anywherecommerce.android.sdk.RequestListener;
import com.anywherecommerce.android.sdk.SDKManager;
import com.anywherecommerce.android.sdk.Terminal;
import com.anywherecommerce.android.sdk.TerminalNotInitializedException;
import com.anywherecommerce.android.sdk.Users;
import com.anywherecommerce.android.sdk.devices.CardInterface;
import com.anywherecommerce.android.sdk.devices.CardReader;
import com.anywherecommerce.android.sdk.devices.CardReaderController;
import com.anywherecommerce.android.sdk.devices.MultipleBluetoothDevicesFoundListener;
import com.anywherecommerce.android.sdk.devices.bbpos.BBPOSDevice;
import com.anywherecommerce.android.sdk.devices.bbpos.BBPOSDeviceCardReaderController;
import com.anywherecommerce.android.sdk.endpoints.AuthenticationListener;
import com.anywherecommerce.android.sdk.endpoints.anywherecommerce.AnyPayCardTransaction;
import com.anywherecommerce.android.sdk.endpoints.anywherecommerce.AnyPayReferenceTransaction;
import com.anywherecommerce.android.sdk.endpoints.anywherecommerce.AnyPayTransaction;
import com.anywherecommerce.android.sdk.endpoints.worldnet.WorldnetEndpoint;
import com.anywherecommerce.android.sdk.endpoints.worldnet.WorldnetReferenceTransaction;
import com.anywherecommerce.android.sdk.endpoints.worldnet.WorldnetTerminal;
import com.anywherecommerce.android.sdk.endpoints.worldnet.WorldnetTerminalConfiguration;
import com.anywherecommerce.android.sdk.endpoints.worldnet.WorldnetTransaction;
import com.anywherecommerce.android.sdk.models.DrawPoint;
import com.anywherecommerce.android.sdk.models.Signature;
import com.anywherecommerce.android.sdk.models.TaxLineItem;
import com.anywherecommerce.android.sdk.models.TipLineItem;
import com.anywherecommerce.android.sdk.models.TransactionType;
import com.anywherecommerce.android.sdk.transactions.listener.CardTransactionListener;
import com.anywherecommerce.android.sdk.transactions.listener.TransactionListener;
import com.anywherecommerce.android.sdk.util.Amount;
import com.bbpos.DecryptedData;
import com.bbpos.EmvSwipeDecrypt;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;

import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CallbackContext;

import org.apache.cordova.PluginResult;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.json.JSONTokener;

import android.os.Handler;
import android.telecom.Call;
import android.util.Log;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.EnumSet;
import java.util.HashMap;
import java.util.List;
import java.util.stream.Collectors;

import android.bluetooth.BluetoothDevice;

//import us.fatehi.creditcardnumber.ServiceCode;
//import us.fatehi.magnetictrack.bankcard.BankCardMagneticTrack;
//import us.fatehi.magnetictrack.bankcard.Track1FormatB;
//import us.fatehi.magnetictrack.bankcard.Track2;

import android.content.SharedPreferences;
import android.preference.PreferenceManager;

/**
 * This class echoes a string called from JavaScript.
 */
public class AnyPayCordova extends CordovaPlugin {

    CardReaderController cardReaderController;
    Terminal terminal;
    CallbackContext readerConnectedCallbackContext;
    CallbackContext readerDisconnectedCallbackContext;
    CallbackContext readerConnectionFailedCallbackContext;
    CallbackContext readerConnectionErrorCallbackContext;
    CallbackContext transactionCallbackContext;
    CallbackContext cardReaderEventCallbackContext;
    CallbackContext signatureRequiredCallbackContext;
    AnyPayTransaction refTransaction;

    @Override
    public boolean execute(String action, final JSONArray args, final CallbackContext callbackContext) throws JSONException {
        if (action.equals("authenticateWorldnetTerminal")) {
            String message = args.getString(0);
            this.authenticateWorldnetTerminal(args.getString(0), args.getString(1), args.getString(2), callbackContext);
            return true;
        }
        else if (action.equals("initializeSDK")) {
            this.initialize(callbackContext);
            return true;
        }
        else if (action.equals("connectToBluetoothReader")) {

            cordova.getActivity().runOnUiThread(new Runnable() {
                public void run() {
                    AnyPayCordova.this.connectToBluetoothReader();
                }
            });

            return true;
        }
        else if (action.equals("connectAudioReader")) {

            cordova.getActivity().runOnUiThread(new Runnable() {
                public void run() {
                    AnyPayCordova.this.connectAudioReader();
                }
            });

            return true;
        }
        else if (action.equals("startEMVSale")) {
            transactionCallbackContext = callbackContext;
            cordova.getActivity().runOnUiThread(new Runnable() {
                public void run() {
                    try {

                        JSONObject transactionJSON = args.getJSONObject(0);

                        AnyPayCordova.this.startEMVSale(createTransactionObject(transactionJSON), callbackContext);
                    }
                    catch (Exception e) {

                    }
                }
            });

            return true;
        }
        else if (action.equals("startKeyedTransaction")) {
            transactionCallbackContext = callbackContext;
            cordova.getActivity().runOnUiThread(new Runnable() {
                public void run() {
                    try {

                        JSONObject transactionJSON = args.getJSONObject(0);
                        AnyPayCordova.this.startKeyedTransaction(createTransactionObject(transactionJSON), callbackContext);
                    }
                    catch (Exception e) {
                        Logger.logException(e);
                    }
                }
            });

            return true;
        }
        else if (action.equals("subscribeOnCardReaderConnected")) {
            readerConnectedCallbackContext = callbackContext;
            cordova.getActivity().runOnUiThread(new Runnable() {
                public void run() {
                    AnyPayCordova.this.subscribeOnCardReaderConnected(callbackContext);
                }
            });

            return true;
        }
        else if (action.equals("subscribeOnCardReaderDisconnected")) {
            readerDisconnectedCallbackContext = callbackContext;
            cordova.getActivity().runOnUiThread(new Runnable() {
                public void run() {
                    AnyPayCordova.this.subscribeOnCardReaderDisconnected(callbackContext);
                }
            });

            return true;
        }
        else if (action.equals("subscribeOnCardReaderConnectFailed")) {
            readerConnectionFailedCallbackContext = callbackContext;
            cordova.getActivity().runOnUiThread(new Runnable() {
                public void run() {
                    AnyPayCordova.this.subscribeOnCardReaderConnectFailed(callbackContext);
                }
            });

            return true;
        }
        else if (action.equals("subscribeOnCardReaderError")) {
            readerConnectionErrorCallbackContext = callbackContext;
            cordova.getActivity().runOnUiThread(new Runnable() {
                public void run() {
                    AnyPayCordova.this.subscribeOnCardReaderError(callbackContext);
                }
            });

            return true;
        }
        else if (action.equals("subscribeToCardReaderEvent")) {
            cordova.getActivity().runOnUiThread(new Runnable() {
                public void run() {
                    AnyPayCordova.this.subscribeToCardReaderEvent(callbackContext);
                }
            });

            return true;
        }
        else if (action.equals("disconnectReader")) {
            cordova.getActivity().runOnUiThread(new Runnable() {
                public void run() {
                    AnyPayCordova.this.disconnectReader();
                }
            });

            return true;
        }
        else if (action.equals("proceed")) {
            cordova.getActivity().runOnUiThread(new Runnable() {
                public void run() {
                    try {
                        AnyPayCordova.this.proceed(jsonArraytoArrayList(args.getJSONArray(0)), callbackContext);
                    }
                    catch (Exception e) {
                        Logger.logException(e);
                    }
                }
            });

            return true;
        }
        else if (action.equals("setOnSignatureRequired")) {
            cordova.getActivity().runOnUiThread(new Runnable() {
                public void run() {
                    try {
                        AnyPayCordova.this.setOnSignatureRequired(callbackContext);
                    }
                    catch (Exception e) {

                    }
                }
            });

            return true;
        }
        else if (action.equals("disconnectReader")) {
            cordova.getActivity().runOnUiThread(new Runnable() {
                public void run() {
                    AnyPayCordova.this.disconnectReader();
                }
            });

            return true;
        }
        else if (action.equals("fetchTransactions")) {
            cordova.getActivity().runOnUiThread(new Runnable() {
                public void run() {
                    try {
                        AnyPayCordova.this.fetchTransactions(args.getInt(0), args.getString(1), callbackContext);
                    }
                    catch (Exception e){}
                }
            });

            return true;
        }
        else if (action.equals("adjustTip")) {
            cordova.getActivity().runOnUiThread(new Runnable() {
                public void run() {
                    try {
                        AnyPayCordova.this.adjustTip(args.getString(0), callbackContext);
                    }catch (Exception e){}
                }
            });

            return true;
        }
        else if (action.equals("updateSignature")) {
            cordova.getActivity().runOnUiThread(new Runnable() {
                public void run() {
                    try {
                        AnyPayCordova.this.updateSignature(jsonArraytoArrayList(args.getJSONArray(0)), callbackContext);
                    }catch (Exception e){}
                }
            });

            return true;
        }
        else if (action.equals("sendReceipt")) {
            cordova.getActivity().runOnUiThread(new Runnable() {
                public void run() {
                    try {
                        AnyPayCordova.this.sendReceipt(args.getString(0), callbackContext);
                    }catch (Exception e){}
                }
            });

            return true;
        }

        return false;
    }


    private void initialize(CallbackContext callbackContext) {
        SDKManager.initialize(this.cordova.getActivity().getApplication());

        cardReaderController = CardReaderController.getControllerFor(BBPOSDevice.class);

        callbackContext.success();
    }

    private void authenticateWorldnetTerminal(String terminalId, String terminalSecret, String gatewayUrl, final CallbackContext callbackContext) {

        Terminal.initializeAs(new WorldnetTerminal(terminalId, terminalSecret));
        ((WorldnetTerminal)Terminal.getInstance()).getEndpoint().setUrl(gatewayUrl);

        Terminal.getInstance().authenticate(new AuthenticationListener() {
            @Override
            public void onAuthenticationComplete() {
                callbackContext.success();
            }

            @Override
            public void onAuthenticationFailed(MeaningfulError error) {
                callbackContext.error(error.message);
            }
        });
    }

    private void disconnectReader() {
        cardReaderController.disconnectReader();
    }

    private void subscribeOnCardReaderConnected(final CallbackContext callbackContext) {
        cardReaderController.subscribeOnCardReaderConnected(new GenericEventListenerWithParam<CardReader>() {
            @Override
            public void onEvent(final CardReader deviceInfo) {

                cordova.getActivity().runOnUiThread(new Runnable() {
                    public void run() {

                        String message = "";

                        if ( deviceInfo == null )
                            message = "Unknown Device Connected";
                        else
                            message = deviceInfo.toString();

                        PluginResult result = new PluginResult(PluginResult.Status.OK, message);
                        result.setKeepCallback(true);
                        readerConnectedCallbackContext.sendPluginResult(result);
                    }
                });

            }
        });
    }

    private void subscribeOnCardReaderDisconnected(final CallbackContext callbackContext) {
        cardReaderController.subscribeOnCardReaderDisconnected(new GenericEventListener() {
            @Override
            public void onEvent() {

                cordova.getActivity().runOnUiThread(new Runnable() {
                    public void run() {

                        PluginResult result = new PluginResult(PluginResult.Status.OK, "Reader Disconnected");
                        result.setKeepCallback(true);
                        readerDisconnectedCallbackContext.sendPluginResult(result);
                    }
                });

            }
        });
    }

    private void subscribeOnCardReaderConnectFailed(final CallbackContext callbackContext) {
        cardReaderController.subscribeOnCardReaderConnectFailed(new MeaningfulErrorListener() {
            @Override
            public void onError(final MeaningfulError meaningfulError) {
                cordova.getActivity().runOnUiThread(new Runnable() {
                    public void run() {

                        String message = "\nDevice connect failed: " + meaningfulError.toString();

                        PluginResult result = new PluginResult(PluginResult.Status.ERROR, message);
                        result.setKeepCallback(true);
                        readerConnectionFailedCallbackContext.sendPluginResult(result);
                    }
                });
            }
        });
    }

    private void subscribeOnCardReaderError(final CallbackContext callbackContext) {
        cardReaderController.subscribeOnCardReaderError(new MeaningfulErrorListener() {
            @Override
            public void onError(final MeaningfulError meaningfulError) {
                cordova.getActivity().runOnUiThread(new Runnable() {
                    public void run() {

                        String message = "\nDevice Error: " + meaningfulError.toString();

                        PluginResult result = new PluginResult(PluginResult.Status.ERROR, message);
                        result.setKeepCallback(true);
                        readerConnectionErrorCallbackContext.sendPluginResult(result);
                    }
                });
            }
        });
    }

    private void connectToBluetoothReader() {


        cardReaderController.connectBluetooth(new MultipleBluetoothDevicesFoundListener() {
            @Override
            public void onMultipleBluetoothDevicesFound(List<BluetoothDevice> matchingDevices) {
                cardReaderController.connectSpecificBluetoothDevice(matchingDevices.get(0));
            }
        });

    }

    private void connectAudioReader() {
        cardReaderController.connectAudioJack();
    }

    private void createWorldnetTransaction(CallbackContext callbackContext) {
        final WorldnetTransaction t = new WorldnetTransaction();

    }

    private void subscribeToCardReaderEvent(final CallbackContext callbackContext) {
        cardReaderEventCallbackContext = callbackContext;
    }

    private void startEMVSale(AnyPayTransaction transaction, final CallbackContext callbackContext) {

        if ( !CardReaderController.isCardReaderConnected() ) {
            callbackContext.error("No Card Reader connected");
            return;
        }

        final WorldnetTransaction t = (WorldnetTransaction)transaction;
        t.useCardReader(CardReaderController.getConnectedReader()); // either instance, or

        refTransaction = t;

        t.setOnSignatureRequiredListener(new GenericEventListener() {
            @Override
            public void onEvent() {
                signatureRequiredCallbackContext.success();
            }
        });

        t.execute(new CardTransactionListener() {
            @Override
            public void onCardReaderEvent(MeaningfulMessage event) {

                PluginResult result = new PluginResult(PluginResult.Status.OK, event.message);
                result.setKeepCallback(true);
                cardReaderEventCallbackContext.sendPluginResult(result);
            }

            @Override
            public void onTransactionCompleted() {

                try {
                    JSONObject transactionObject = new JSONObject(t.serialize());
                    transactionObject.put("approved", t.isApproved());
                    transactionObject.put("internalId", t.getInternalId());

                    PluginResult result = new PluginResult(PluginResult.Status.OK, transactionObject);
                    result.setKeepCallback(false);
                    transactionCallbackContext.sendPluginResult(result);
                }
                catch (Exception e) {

                }


            }

            @Override
            public void onTransactionFailed(MeaningfulError reason) {


                PluginResult result = new PluginResult(PluginResult.Status.ERROR, reason.message);
                result.setKeepCallback(false);
                transactionCallbackContext.sendPluginResult(result);

            }
        });

    }

    private void startKeyedTransaction(AnyPayTransaction transaction, final CallbackContext callbackContext) {

        if ((transaction.getTransactionType() == TransactionType.VOID) || (transaction.getTransactionType() == TransactionType.REFUND) || (transaction.getTransactionType() == TransactionType.REVERSEAUTH)) {
            if (transaction.getExternalId() != null) {
                if (transaction.getExternalId().length() > 0)
                    transaction = (WorldnetReferenceTransaction)((WorldnetTransaction)transaction).createReversal();
            }
        }

        final AnyPayCardTransaction t = (AnyPayCardTransaction) transaction;

        refTransaction = t;

        t.execute(new TransactionListener() {

            @Override
            public void onTransactionCompleted() {


                try {
                    JSONObject transactionObject = new JSONObject(t.serialize());
                    transactionObject.put("approved", t.isApproved());
                    transactionObject.put("internalId", t.getInternalId());

                    PluginResult result = new PluginResult(PluginResult.Status.OK, transactionObject);
                    result.setKeepCallback(false);
                    transactionCallbackContext.sendPluginResult(result);
                }
                catch (Exception e) {

                }

            }

            @Override
            public void onTransactionFailed(MeaningfulError reason) {


                PluginResult result = new PluginResult(PluginResult.Status.ERROR, reason.message);
                result.setKeepCallback(false);
                transactionCallbackContext.sendPluginResult(result);

            }
        });

    }

    private AnyPayTransaction createTransactionObject(JSONObject transactionJSON) {
        AnyPayTransaction transaction = Terminal.getInstance().getEndpoint().createTransaction(WorldnetTransaction.class);

        try {
            if (!transactionJSON.isNull("type"))
                transaction.setTransactionType(TransactionType.fromValue(transactionJSON.getString("type")));

            if (!transactionJSON.isNull("totalAmount"))
                transaction.setTotalAmount(new Amount(transactionJSON.getString("totalAmount")));

            if (!transactionJSON.isNull("subtotal"))
                transaction.setSubtotal(new Amount(transactionJSON.getString("subtotal")));

            if (!transactionJSON.isNull("tax"))
                transaction.addTax(new TaxLineItem("Tax", transactionJSON.getString("tax")));

            if (!transactionJSON.isNull("tip"))
                transaction.setTip(new TipLineItem(transactionJSON.getString("tip")));

            if (!transactionJSON.isNull("currency"))
                transaction.setCurrency(transactionJSON.getString("currency"));

            if (!transactionJSON.isNull("cardExpiryMonth"))
                ((AnyPayCardTransaction)transaction).setCardExpiryMonth(transactionJSON.getString("cardExpiryMonth"));

            if (!transactionJSON.isNull("cardExpiryYear"))
                ((AnyPayCardTransaction)transaction).setCardExpiryYear(transactionJSON.getString("cardExpiryYear"));

            if (!transactionJSON.isNull("cardNumber"))
                ((AnyPayCardTransaction)transaction).setCardNumber(transactionJSON.getString("cardNumber"));

            if (!transactionJSON.isNull("CVV2"))
                ((AnyPayCardTransaction)transaction).setCVV2(transactionJSON.getString("CVV2"));

            if (!transactionJSON.isNull("maskedPAN"))
                ((AnyPayCardTransaction)transaction).setMaskedPAN(transactionJSON.getString("maskedPAN"));

            if (!transactionJSON.isNull("address"))
                ((AnyPayCardTransaction)transaction).setAddress(transactionJSON.getString("address"));

            if (!transactionJSON.isNull("cardholderName"))
                ((AnyPayCardTransaction)transaction).setCardholderName(transactionJSON.getString("cardholderName"));

            if (!transactionJSON.isNull("postalCode"))
                ((AnyPayCardTransaction)transaction).setPostalCode(transactionJSON.getString("postalCode"));

            if (!transactionJSON.isNull("internalId"))
                ((AnyPayCardTransaction)transaction).setInternalId(transactionJSON.getString("internalId"));

            if (!transactionJSON.isNull("externalId"))
                ((AnyPayCardTransaction)transaction).setExternalId(transactionJSON.getString("externalId"));

            if (!transactionJSON.isNull("cardInterfaceModes")) {
                JSONArray arr = transactionJSON.getJSONArray("cardInterfaceModes");
                List<String> list = new ArrayList<String>();
                for (int i = 0; i < arr.length();list.add(arr.getString(i++)));

                StringBuilder builder = new StringBuilder();

                for (String string : list) {
                    if (builder.length() > 0) {
                        builder.append(" ");
                    }

                    builder.append(string);
                }

                if (CardReaderController.getConnectedReader() != null)
                    CardReaderController.getConnectedReader().setEnabledInterfaces(getEnumsetForEntryModes(builder.toString()));
            }

            return transaction;
        }
        catch (JSONException ex) {

        }

        return null;
    }

    private static EnumSet<CardInterface> getEnumsetForEntryModes(String entrymodes) {
        EnumSet<CardInterface> enabledEntryModes = EnumSet.noneOf(CardInterface.class);

        entrymodes = entrymodes.replace("DIP", CardInterface.INSERT.toString());
        entrymodes = entrymodes.replace("NFC", CardInterface.TAP.toString());
        entrymodes = entrymodes.replace("KEYED", CardInterface.PINPAD.toString());

        if (entrymodes.contains(CardInterface.SWIPE.toString()))
            enabledEntryModes.add(CardInterface.SWIPE);
        if (entrymodes.contains(CardInterface.INSERT.toString()))
            enabledEntryModes.add(CardInterface.INSERT);
        if (entrymodes.contains(CardInterface.TAP.toString()))
            enabledEntryModes.add(CardInterface.TAP);
        if (entrymodes.contains(CardInterface.PINPAD.toString()))
            enabledEntryModes.add(CardInterface.PINPAD);
        if (entrymodes.contains(CardInterface.OCR.toString()))
            enabledEntryModes.add(CardInterface.OCR);

        return enabledEntryModes;
    }

    private void setOnSignatureRequired(final CallbackContext callbackContext) {
        signatureRequiredCallbackContext = callbackContext;
    }

    private void proceed(ArrayList<ArrayList> signaturePoints, CallbackContext callbackContext) {
        ((AnyPayCardTransaction)refTransaction).setSignature(pointsToSignatureArray(signaturePoints));
        refTransaction.proceed();
    }

    private void adjustTip(String rate, final CallbackContext callbackContext) {
        ((WorldnetTransaction)refTransaction).updateTipAdjustment(new TipLineItem(rate), new RequestListener() {
            @Override
            public void onRequestComplete(Object response) {
                callbackContext.success();
            }

            @Override
            public void onRequestFailed(MeaningfulError reason) {
                callbackContext.error(reason.message);
            }
        });
    }

    private void updateSignature(ArrayList<ArrayList> signaturePoints, final CallbackContext callbackContext) {
        if (signaturePoints.size() > 0) {
            ((WorldnetTransaction)refTransaction).updateSignature(pointsToSignatureArray(signaturePoints), new RequestListener() {
                @Override
                public void onRequestComplete(Object response) {
                    callbackContext.success();
                }

                @Override
                public void onRequestFailed(MeaningfulError reason) {
                    callbackContext.error(reason.message);
                }
            });
        }
        else {
            callbackContext.error("Signature array is empty");
        }
    }

    private void fetchTransactions(int page, String orderID, final CallbackContext callbackContext) {
        WorldnetEndpoint.fetchTransactions(page, orderID, "", "", new RequestListener<ArrayList<WorldnetTransaction>>() {
            @Override
            public void onRequestComplete(ArrayList<WorldnetTransaction> o) {

                JSONArray a = new JSONArray();
                for (WorldnetTransaction t : o) {
                    a.put(t.serialize());
                }

                callbackContext.success(a);
            }

            @Override
            public void onRequestFailed(MeaningfulError meaningfulError) {

            }
        });
    }

    private void sendReceipt(String to, final CallbackContext callbackContext) {
        refTransaction.sendReceipt(to, new RequestListener() {
            @Override
            public void onRequestComplete(Object o) {
                callbackContext.success();
            }

            @Override
            public void onRequestFailed(MeaningfulError meaningfulError) {
                callbackContext.error(meaningfulError.message);
            }
        });
    }

    private Signature pointsToSignatureArray(ArrayList<ArrayList> sPoints) {
        try {
            Signature signature = new Signature();
            ArrayList<DrawPoint> signaturePoints = new ArrayList<DrawPoint>();

            for (ArrayList<JSONObject> pointsDict:sPoints) {
                for (int i=0; i<pointsDict.size(); i++) {
                    DrawPoint point = new DrawPoint();

                    float x = ((Double)pointsDict.get(i).getDouble("x")).floatValue();
                    float y = ((Double)pointsDict.get(i).getDouble("y")).floatValue();

                    if (i == 0)
                        point.setStart(x, y);
                    else if (i == pointsDict.size() - 1)
                        point.setEnd(x, y);
                    else
                        point.setMove(x, y);

                    signaturePoints.add(point);
                }
            }

            signature.setSignaturePoints(signaturePoints);
            return signature;
        }
        catch (Exception e) {

        }

        return null;
    }

    private ArrayList jsonArraytoArrayList(JSONArray jArray) {
        try {
            ArrayList listdata = new ArrayList();
            if (jArray != null) {
                for (int i=0; i<jArray.length(); i++) {

                    Object a = jArray.get(i);
                    if (a instanceof JSONArray) {
                        a = jsonArraytoArrayList((JSONArray) a);
                    }

                    listdata.add(a);
                }
            }

            return listdata;
        }
        catch (Exception e) {

        }

        return null;
    }

}
