
import Cycles "mo:base/ExperimentalCycles";
import HashMap "mo:base/HashMap";
import Principal "mo:base/Principal";
import Result "mo:base/Result";
import Iter "mo:base/Iter";
import Array "mo:base/Array";
import Time "mo:base/Time";
import Nat64 "mo:base/Nat64";
import List "mo:base/List";

//Get the path right
import AID "../motoko/util/AccountIdentifier";
import ExtCore "../motoko/ext/Core";
import ExtCommon "../motoko/ext/Common";
import ExtArchive "../motoko/ext/Archive";

module ICET = {
  // Types
  type AccountIdentifier = ExtCore.AccountIdentifier;
  type SubAccount = ExtCore.SubAccount;
  type User = ExtCore.User;
  type Balance = ExtCore.Balance;
  type TokenIdentifier = ExtCore.TokenIdentifier;
  type Memo = ExtCore.Memo;
  type Extension = ExtCore.Extension;
  type CommonError = ExtCore.CommonError;
  type NotifyService = ExtCore.NotifyService;
  
  type BalanceRequest = ExtCore.BalanceRequest;
  type BalanceResponse = ExtCore.BalanceResponse;
  type TransferRequest = ExtCore.TransferRequest;
  type TransferResponse = ExtCore.TransferResponse;
  type TransferIdResponse = ExtCore.TransferIdResponse;
  type Metadata = ExtCommon.Metadata;
  //archive
  type TransactionId = ExtArchive.TransactionId;
  type Transaction = ExtArchive.Transaction;
  type TransactionsRequest = ExtArchive.TransactionsRequest;
  
   public type TransactionVerifyRequest = {
    from : User;
    to : User;
    amount : Balance;
    memo : Memo;
  };
}
