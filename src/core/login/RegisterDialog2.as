package core.login {
import core.hud.components.LoginButton;
import core.hud.components.LoginInput;

import flash.net.SharedObject;

import generics.Localize;

import playerio.Client;
import playerio.PlayerIO;
import playerio.PlayerIORegistrationError;

import starling.core.Starling;
import starling.display.Sprite;

public class RegisterDialog2 extends Sprite {
    public function RegisterDialog2(login:Login) {
        var cancelButton:LoginButton;
        super();
        var registerBox:starling.display.Sprite = new Sprite();
        emailInput = new LoginInput(Localize.t("Email"));
        registerBox.addChild(emailInput);
        nameInput = new LoginInput(Localize.t("Name"));
        nameInput.setPrevious(emailInput);
        registerBox.addChild(nameInput);
        passwordInput = new LoginInput(Localize.t("Password"));
        passwordInput.setPrevious(nameInput);
        passwordInput.input.displayAsPassword = true;
        registerBox.addChild(passwordInput);
        passwordConfirmInput = new LoginInput(Localize.t("Password again"));
        passwordConfirmInput.setPrevious(passwordInput);
        passwordConfirmInput.input.displayAsPassword = true;
        registerBox.addChild(passwordConfirmInput);
        registerButton = new LoginButton(Localize.t("Confirm"), onRegisterSimple, 325961);
        registerButton.y = passwordConfirmInput.y + 70;
        registerBox.addChild(registerButton);
        cancelButton = new LoginButton(Localize.t("Cancel"), function ():void {
            Starling.current.nativeStage.focus = null;
            login.setState("site");
        });
        cancelButton.x = registerBox.width - cancelButton.width;
        cancelButton.y = registerButton.y;
        registerBox.addChild(cancelButton);
        addChild(registerBox);
    }

    private var username:String;
    private var client:Client;
    private var registerButton:LoginButton;
    private var emailInput:LoginInput;
    private var nameInput:LoginInput;
    private var passwordInput:LoginInput;
    private var passwordConfirmInput:LoginInput;

    public function onRegisterSimple():void {
        var _loc5_:String = trim(emailInput.text);
        var _loc3_:String = trim(nameInput.text);
        var _loc1_:String = trim(passwordInput.text);
        var _loc2_:String = trim(passwordConfirmInput.text);
        emailInput.error = "";
        nameInput.error = "";
        passwordInput.error = "";
        passwordConfirmInput.error = "";
        var _loc4_:Boolean = false;
        if (_loc5_.length == 0 || !isValidEmail(_loc5_)) {
            emailInput.error = Localize.t("Invalid");
            _loc4_ = true;
        }
        if (_loc3_.length < 3) {
            nameInput.error = Localize.t("Too short").replace("[n]", 3);
            _loc4_ = true;
        }
        if (_loc1_.length < 4) {
            passwordInput.error = Localize.t("Too short").replace("[n]", 4);
            _loc4_ = true;
        } else if (_loc1_.toLowerCase() == _loc3_.toLowerCase()) {
            passwordInput.error = Localize.t("Too simple");
            _loc4_ = true;
        } else if (_loc1_ != _loc2_) {
            passwordConfirmInput.error = Localize.t("Don\'t match");
            _loc4_ = true;
        }
        if (emailInput.error.length != 0 || passwordInput.error.length != 0 || nameInput.error.length != 0) {
            registerButton.enabled = true;
            return;
        }
        if (_loc4_) {
            registerButton.enabled = true;
        }
        username = _loc3_;
        updateStatus(Localize.t("Creating new user..."));
        if (client != null) {
            handleConnect(client);
        } else {
            register(_loc5_, _loc1_);
        }
    }

    private function register(email:String, password:String):void {
        var mySharedObject:flash.net.SharedObject = SharedObject.getLocal("AstrofluxLogin");
        mySharedObject.data.email = email;
        mySharedObject.flush();
        var _loc3_:Date = new Date();
        PlayerIO.quickConnect.simpleRegister(Starling.current.nativeStage, Login.gameId, _loc3_.getTime().toString(), password, email, null, null, null, Login.partnerId, RymdenRunt.partnerSegmentArray, handleConnect, handleRegError);
    }

    private function updateStatus(message:String = ""):void {
        var _loc2_:ConnectEvent = new ConnectEvent("connectStatus", true);
        _loc2_.message = message;
        dispatchEvent(_loc2_);
    }

    private function handleConnect(client:Client):void {
        this.client = client;
        Starling.current.nativeStage.focus = null;
        emailInput.text = "";
        nameInput.text = "";
        passwordInput.text = "";
        passwordConfirmInput.text = "";
        removeChild(emailInput);
        removeChild(nameInput);
        removeChild(passwordInput);
        removeChild(passwordConfirmInput);
        var _loc2_:ConnectEvent = new ConnectEvent("fbConnect");
        _loc2_.client = client;
        _loc2_.joinData["name"] = username;
        dispatchEvent(_loc2_);
    }

    private function handleRegError(e:PlayerIORegistrationError):void {
        updateStatus();
        emailInput.error = e.emailError;
        passwordInput.error = e.passwordError;
        registerButton.enabled = true;
    }

    private function isValidEmail(email:String):Boolean {
        var _loc2_:RegExp = /^[0-9a-zA-Z][-._a-zA-Z0-9]*@([0-9a-zA-Z][-._0-9a-zA-Z]*\.)+[a-zA-Z]/;
        return _loc2_.test(email);
    }

    private function trim(s:String):String {
        return s.replace(/^([\s|\t|\n]+)?(.*)([\s|\t|\n]+)?$/gm, "$2");
    }
}
}

