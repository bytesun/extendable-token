/*
ERC721 - note the following:
-No notifications (can be added)
-All tokenids are ignored
-You can use the canister address as the token id
-Memo is ignored
-No transferFrom (as transfer includes a from field)
*/
import Cycles "mo:base/ExperimentalCycles";
import HashMap "mo:base/HashMap";
import Principal "mo:base/Principal";
import Result "mo:base/Result";
import Iter "mo:base/Iter";
import Array "mo:base/Array";
import Time "mo:base/Time";
import Nat64 "mo:base/Nat64";
import Buffer "mo:base/Buffer";
import Random "mo:base/Random";
import Nat32 "mo:base/Nat32";
import Nat "mo:base/Nat";
import Text "mo:base/Text";
import Blob "mo:base/Blob";

import AID "../motoko/util/AccountIdentifier";
import ExtCore "../motoko/ext/Core";
import ExtCommon "../motoko/ext/Common";
import ExtAllowance "../motoko/ext/Allowance";
import ExtNonFungible "../motoko/ext/NonFungible";
import ExtArchive "../motoko/ext/Archive";
import Ext "mo:ext/Ext";

import NFTicket "../ticket/NFTicket";
import CDNTypes "../asset/Types";

import Http "../http";
import HttpTypes "../http/types";

shared (install) actor class iceventicket() = this {
  
  // Types
  type AccountIdentifier = ExtCore.AccountIdentifier;
  type SubAccount = ExtCore.SubAccount;
  type User = ExtCore.User;
  type Balance = ExtCore.Balance;
  type TokenIdentifier = ExtCore.TokenIdentifier;
  type TokenIndex  = ExtCore.TokenIndex ;
  type Extension = ExtCore.Extension;
  type CommonError = ExtCore.CommonError;
  type BalanceRequest = ExtCore.BalanceRequest;
  type BalanceResponse = ExtCore.BalanceResponse;
  type TransferRequest = ExtCore.TransferRequest;
  type TransferResponse = ExtCore.TransferResponse;
  type AllowanceRequest = ExtAllowance.AllowanceRequest;
  type ApproveRequest = ExtAllowance.ApproveRequest;
  type Metadata = NFTicket.Metadata;
    //archive
  type TransactionId = ExtArchive.TransactionId;
  type Transaction = ExtArchive.Transaction;
  type TransactionsRequest = ExtArchive.TransactionsRequest;

  type MintRequest  = ExtNonFungible.MintRequest ;
  type MintTicketRequest = NFTicket.MintTicketRequest;

  type Minter = {
    minter: Principal;
    quota: Nat;
    minted: [TokenIndex];
  };
  private let EXTENSIONS : [Extension] = ["@ext/common","@ext/archive", "@ext/allowance", "@ext/nonfungible"];
  
  let storage: CDNTypes.Self = actor "5pqgi-saaaa-aaaal-aaavq-cai";

  //State work
  private stable var _registryState : [(TokenIndex, AccountIdentifier)] = [];
  private var _registry : HashMap.HashMap<TokenIndex, AccountIdentifier> = HashMap.fromIter(_registryState.vals(), 0, ExtCore.TokenIndex.equal, ExtCore.TokenIndex.hash);
	
  private stable var _allowancesState : [(TokenIndex, Principal)] = [];
  private var _allowances : HashMap.HashMap<TokenIndex, Principal> = HashMap.fromIter(_allowancesState.vals(), 0, ExtCore.TokenIndex.equal, ExtCore.TokenIndex.hash);
	
	private stable var _tokenMetadataState : [(TokenIndex, Metadata)] = [];
  private var _tokenMetadata : HashMap.HashMap<TokenIndex, Metadata> = HashMap.fromIter(_tokenMetadataState.vals(), 0, ExtCore.TokenIndex.equal, ExtCore.TokenIndex.hash);



  private stable var _nextTransationId : TransactionId = 1;
  private stable var _transactions : [Transaction] = [];

  private stable var _supply : Balance  = 0;
  private stable var _admin : Principal  = install.caller;
  private stable var _moderators : [Principal] = [install.caller];
  private stable var _minters : [Minter] = [];
  private stable var _nextTokenId : TokenIndex  = 0;
  private stable var _asset : ?Blob = null;  

  //State functions
  system func preupgrade() {
    _registryState := Iter.toArray(_registry.entries());
    _allowancesState := Iter.toArray(_allowances.entries());
    _tokenMetadataState := Iter.toArray(_tokenMetadata.entries());
  };
  system func postupgrade() {
    _registryState := [];
    _allowancesState := [];
    _tokenMetadataState := [];
  };


  public shared({caller}) func addModerator(mod : Principal): async (){
    assert(caller == _admin);
    _moderators := Array.append<Principal>([mod],_moderators) ;
  };

	public shared(msg) func setMinter(minter : Principal, quota: Nat) : async Result.Result<Nat, Text> {
    let fmod = Array.find(_moderators,func(m: Principal): Bool{
      m == msg.caller
    });
	switch(fmod){
    case(?fmod){
     let fminter = Array.find<Minter>(_minters, func(m){
        m.minter == minter
      });
      switch(fminter){
        case(?fminter){
          //add more quota
          _minters := Array.map<Minter,Minter>(_minters, func(m:Minter): Minter{
            if(m.minter == minter){ 
              {
                minter = m.minter;
                quota = m.quota + quota;
                minted = m.minted;
              }
            }else{
              m
            }
          })       
        };
        case(_){
          _minters := Array.append<Minter>([{minter=minter;quota=quota;minted=[]}],_minters);
        };
      };
      #ok(1);
    };
    case(_){
      #err("no permission!")
    };
  }
 
   
    
		//_minter := minter;
	};
	
  //default asset
  public shared(msg) func setDefaultAsset(asset: ?Blob): async (){   
        _asset := asset;     
  };

  // public shared(msg) func mintNFT(request : MintRequest) : async Result.Result<TokenIndex,Text> {
	// 	//assert(msg.caller == _minter);
  //   let fminter = Array.find<Minter>(_minters, func(m){
  //     m.minter == msg.caller;
  //   });
  //   switch(fminter){
  //     case(?fminter){
  //       if(fminter.quota > fminter.minted.size()){
  //         let receiver = ExtCore.User.toAID(request.to);
  //         let token = _nextTokenId;
  //         let md : Metadata = #nonfungible({
  //           metadata = request.metadata;
  //         }); 
  //         _registry.put(token, receiver);
  //         _tokenMetadata.put(token, md);
  //         _supply := _supply + 1;
  //         _nextTokenId := _nextTokenId + 1;

  //         //update minter data
  //         var minted = fminter.minted;
  //         minted := Array.append<TokenIndex>([token],minted);
  //         _minters := Array.map<Minter,Minter>(_minters,func(m: Minter):Minter{
  //           if(m.minter == fminter.minter){
  //             {
  //               minter = fminter.minter;
  //               quota = fminter.quota;
  //               minted = minted;
  //             }
  //           }else{
  //             m
  //           }
  //         });

  //         #ok(token);
  //       }else{
  //         #err("no more quota to mint!")
  //       };
        
  //     };
  //     case(_){
  //       #err("no permission!")
  //     };
  //   };
    
	// };
  public shared({caller}) func mintEventTickets(request: MintTicketRequest) : async Result.Result<[TokenIndex],Text> {
		//assert(msg.caller == _minter);
    let fminter = Array.find<Minter>(_minters, func(m){
      m.minter == caller;
    });
    let metadatas = request.metadatas;
    switch(fminter){
      case(?fminter){
        if(metadatas.size() > 0 and metadatas.size() <= (fminter.quota - fminter.minted.size())){

          var newIds = Buffer.Buffer<TokenIndex>(metadatas.size());

          for(i in Iter.range(0, metadatas.size()-1)){
            let receiver = ExtCore.User.toAID(#principal(caller));
            let token = _nextTokenId;
            
            // let md : Metadata = #nonfungible({
            //   metadata = ?metadatas[i];
            // }); 

            _registry.put(token, receiver);
            _tokenMetadata.put(token, metadatas[i]);

            if(request.spender != caller) _allowances.put(token,request.spender );

            newIds.add(token);
            _supply := _supply + 1;
            _nextTokenId := _nextTokenId + 1;

          };


            //update minter data
            var minted = fminter.minted;
            minted := Array.append<TokenIndex>(newIds.toArray(),minted);
            _minters := Array.map<Minter,Minter>(_minters,func(m: Minter):Minter{
              if(m.minter == fminter.minter){
                {
                  minter = fminter.minter;
                  quota = fminter.quota;
                  minted = minted;
                }
              }else{
                m
              }
            });
          #ok(newIds.toArray());
        }else{
          #err("no more quota to mint!")
        };
        
      };
      case(_){
        #err("no permission!")
      };
    };
    
	};
   func add(request : TransferRequest):  TransactionId{

    let transid = _nextTransationId;
    _transactions := Array.append<Transaction>([{
      txid = transid;
      request = request;
      date = Nat64.fromIntWrap(Time.now());
    }],_transactions);

    _nextTransationId := _nextTransationId+1;

    transid;
  };

  public query func transactions(request : TransactionsRequest): async Result.Result<[Transaction], ExtCore.CommonError>{
    let q = request.query_option;
    switch(q){
      case(#txid(q)){
        let ts = Array.filter<Transaction>(_transactions, func(t: Transaction): Bool{
          t.txid == q
        });
        #ok(ts);
      };
      case(#user(q)){
        let ts =Array.filter(_transactions,func(t: Transaction): Bool{
          t.request.from == q or t.request.to == q
         });
         #ok(ts);
      };
      case(#date(q)){
        #err(#Other("'date' option is not support"))
      };
      case(#page(q)){
        #err(#Other("'page' option is not support"))
      };
      case(#all(q)){
        #ok(_transactions);
      };
      

    }

  };
  
  public shared(msg) func transfer(request: TransferRequest) : async TransferResponse {
    if (request.amount != 1) {
			return #err(#Other("Must use amount of 1"));
		};
		if (ExtCore.TokenIdentifier.isPrincipal(request.token, Principal.fromActor(this)) == false) {
			return #err(#InvalidToken(request.token));
		};
		let token = ExtCore.TokenIdentifier.getIndex(request.token);
    let owner = ExtCore.User.toAID(request.from);
    let spender = AID.fromPrincipal(msg.caller, request.subaccount);
    let receiver = ExtCore.User.toAID(request.to);
		
    switch (_registry.get(token)) {
      case (?token_owner) {
				if(AID.equal(owner, token_owner) == false) {
					return #err(#Unauthorized(owner));
				};
				if (AID.equal(owner, spender) == false) {
					switch (_allowances.get(token)) {
						case (?token_spender) {
							if(Principal.equal(msg.caller, token_spender) == false) {								
								return #err(#Unauthorized(spender));
							};
						};
						case (_) {
							return #err(#Unauthorized(spender));
						};
					};
				};
				_allowances.delete(token);
				_registry.put(token, receiver);
        let txid = add(request);
				return #ok(request.amount);
        
      };
      case (_) {
        return #err(#InvalidToken(request.token));
      };
    };
  };
  
   public shared({caller}) func transferTicket(to:Principal,token: TokenIndex) : async TransferResponse {


		//let token = ExtCore.TokenIdentifier.getIndex(request.token);
    let owner = ExtCore.User.toAID(#principal(caller));
    let spender = ExtCore.User.toAID(#principal(caller));
    let receiver = ExtCore.User.toAID(#principal(to));
		
    switch (_registry.get(token)) {
      case (?token_owner) {
				if(AID.equal(owner, token_owner) == false) {
          switch (_allowances.get(token)) {
						case (?token_spender) {
							if(Principal.equal(caller, token_spender) == false) {								
								return #err(#Unauthorized(spender));
							};
						};
						case (_) {
							return #err(#Unauthorized(spender));
						};
					};
					// return #err(#Unauthorized(owner));
				};
				// if (AID.equal(owner, spender) == false) {
				// 	switch (_allowances.get(token)) {
				// 		case (?token_spender) {
				// 			if(Principal.equal(caller, token_spender) == false) {								
				// 				return #err(#Unauthorized(spender));
				// 			};
				// 		};
				// 		case (_) {
				// 			return #err(#Unauthorized(spender));
				// 		};
				// 	};
				// };
				_allowances.delete(token);
				_registry.put(token, receiver);

        let txid = add({
          from = #principal(caller);
          to = #principal(to);
          token =  Ext.TokenIdentifier.encode(Principal.fromActor(this),token);
          amount = 1;
          memo = Blob.fromArray([]);
          notify = false;
          subaccount = ?[];
        });
				return #ok(1);
      };
      case (_) {
        let t = Nat32.toText(token);
        return #err(#InvalidToken(t));
      };
    };
  };
  
  public shared(msg) func approve(request: ApproveRequest) : async () {
		if (ExtCore.TokenIdentifier.isPrincipal(request.token, Principal.fromActor(this)) == false) {
			return;
		};
		let token = ExtCore.TokenIdentifier.getIndex(request.token);
    let owner = AID.fromPrincipal(msg.caller, request.subaccount);
		switch (_registry.get(token)) {
      case (?token_owner) {
				if(AID.equal(owner, token_owner) == false) {
					return;
				};
				_allowances.put(token, request.spender);
        return;
      };
      case (_) {
        return;
      };
    };
  };

  public shared({caller}) func setAdmin(newAdmin: Principal): async (){
    assert(caller == _admin);
    _admin := newAdmin;
  };

  public query func getAdmin() : async Principal {
    _admin;
  };
  public query func getModerators() : async [Principal] {
    _moderators;
  };
  public query func getMinters() : async [Minter] {
    _minters;
  };
  
  public query func extensions() : async [Extension] {
    EXTENSIONS;
  };
  
  public query({caller}) func getMyTickets(): async [(TokenIndex, Metadata)]{
   if(Principal.isAnonymous(caller) == false){
    let rtickets = Buffer.Buffer<(TokenIndex, Metadata)>(0);
    let iter = _registry.keys();
    for (k in iter) {

      switch(_registry.get(k)){
        case(?token_owner){
          if (AID.equal(ExtCore.User.toAID(#principal caller), token_owner) == true) {
            let md = _tokenMetadata.get(k);
            
           
            switch(md){
              case(?md){
                // let ti = Ext.TokenIdentifier.encode(Principal.fromActor(this),k);
                rtickets.add((k, md));
              };
              case(_){

              }
            }
            
          }
        };
        case(_){

        }
      }
      
    };
    rtickets.toArray();
   }else{
     []
   }
  };

  public query func balance(request : BalanceRequest) : async BalanceResponse {
		if (ExtCore.TokenIdentifier.isPrincipal(request.token, Principal.fromActor(this)) == false) {
			return #err(#InvalidToken(request.token));
		};
		let token = ExtCore.TokenIdentifier.getIndex(request.token);
    let aid = ExtCore.User.toAID(request.user);
    switch (_registry.get(token)) {
      case (?token_owner) {
				if (AID.equal(aid, token_owner) == true) {
					return #ok(1);
				} else {					
					return #ok(0);
				};
      };
      case (_) {
        return #err(#InvalidToken(request.token));
      };
    };
  };
	
	public query func allowance(request : AllowanceRequest) : async Result.Result<Balance, CommonError> {
		if (ExtCore.TokenIdentifier.isPrincipal(request.token, Principal.fromActor(this)) == false) {
			return #err(#InvalidToken(request.token));
		};
		let token = ExtCore.TokenIdentifier.getIndex(request.token);
		let owner = ExtCore.User.toAID(request.owner);
		switch (_registry.get(token)) {
      case (?token_owner) {
				if (AID.equal(owner, token_owner) == false) {					
					return #err(#Other("Invalid owner"));
				};
				switch (_allowances.get(token)) {
					case (?token_spender) {
						if (Principal.equal(request.spender, token_spender) == true) {
							return #ok(1);
						} else {					
							return #ok(0);
						};
					};
					case (_) {
						return #ok(0);
					};
				};
      };
      case (_) {
        return #err(#InvalidToken(request.token));
      };
    };
  };
  
	public query func bearer(token : TokenIdentifier) : async Result.Result<AccountIdentifier, CommonError> {
		if (ExtCore.TokenIdentifier.isPrincipal(token, Principal.fromActor(this)) == false) {
			return #err(#InvalidToken(token));
		};
		let tokenind = ExtCore.TokenIdentifier.getIndex(token);
    switch (_registry.get(tokenind)) {
      case (?token_owner) {
				return #ok(token_owner);
      };
      case (_) {
        return #err(#InvalidToken(token));
      };
    };
	};
  
	public query func supply(token : TokenIdentifier) : async Result.Result<Balance, CommonError> {
    #ok(_supply);
  };
  
  public query func getRegistry() : async [(TokenIndex, AccountIdentifier)] {
    Iter.toArray(_registry.entries());
  };
  public query func getAllowances() : async [(TokenIndex, Principal)] {
    Iter.toArray(_allowances.entries());
  };
  public query func getTokens() : async [(TokenIndex, Metadata)] {
    Iter.toArray(_tokenMetadata.entries());
  };
  
  public query func metadata(token : TokenIdentifier) : async Result.Result<Metadata, CommonError> {
    if (ExtCore.TokenIdentifier.isPrincipal(token, Principal.fromActor(this)) == false) {
			return #err(#InvalidToken(token));
		};
		let tokenind = ExtCore.TokenIdentifier.getIndex(token);
    switch (_tokenMetadata.get(tokenind)) {
      case (?token_metadata) {
				return #ok(token_metadata);
      };
      case (_) {
        return #err(#InvalidToken(token));
      };
    };
  };
  
  //Internal cycle management - good general case
  public func acceptCycles() : async () {
    let available = Cycles.available();
    let accepted = Cycles.accept(available);
    assert (accepted == available);
  };
  public query func availableCycles() : async Nat {
    return Cycles.balance();
  };


  let _HttpHandler = Http.HttpHandler();


  public query func http_request(request : HttpTypes.Request) : async HttpTypes.Response {
      if (Text.contains(request.url, #text("tokenid"))) {
          let tokenId = Iter.toArray(Text.tokens(request.url, #text("tokenid=")))[1];
          let tokenind = ExtCore.TokenIdentifier.getIndex(tokenId);
           
          switch (_tokenMetadata.get(tokenind)) {
              case (?token_metadata) {
                let fid = token_metadata.asset;
                _HttpHandler.renderMesssage("Token Index:"# Nat32.toText(tokenind) #"\n"  #"\n" #
                "Event ID : "# Nat.toText(token_metadata.event_id) #"\n"  #
                "Event Name :"# token_metadata.event_name #"\n"  #
                "Event Host : "# token_metadata.host #"\n"               
                );
                // switch(fid){
                //   case(?fid){
                //     let f = await storage.fetchFileInfo(fid);                
                //     switch(f){
                //       case(?f){
                //           let fc = await storage.fetchFileChunks(fid);
                //           switch(fc){
                //             case(?fc){
                //                 _HttpHandler.renderTicket(f.extension,Blob.fromArray(fc));  
                //             };
                //             case(_){
                //                 _HttpHandler.renderMesssage("no file data found")
                //             }
                //           }
                            
                //       };
                //       case(_){
                //         _HttpHandler.renderMesssage("no file extention found")
                //       }
                //     };
                    
                   
                //   };
                //   case(_){
                //      _HttpHandler.renderMesssage("no asset associated with the token")
                //   }
                // }
                
              };
              case (_) {
                _HttpHandler.renderMesssage("no token id found!")
              };
            };
      }else{
        _HttpHandler.request(request);
      };         
      
  };
}