/**

 */
import Result "mo:base/Result";

import ExtCore "../motoko/ext/Core";
module NFTicket = {
  public type Metadata = {
    event_id: Nat;
    event_name: Text;
    event_day: Text;
    event_location: Text;
    host: Text;
    asset: ?Text;
    
  };
  
  public type MintTicketRequest = {
    spender : Principal;
    metadatas : [Metadata];
  };


  public type Service = actor {
    metadata: query (token : ExtCore.TokenIdentifier) -> async Result.Result<Metadata, ExtCore.CommonError>;

    supply: query (token : ExtCore.TokenIdentifier) -> async Result.Result<ExtCore.Balance, ExtCore.CommonError>;

    bearer: query (token : ExtCore.TokenIdentifier) -> async Result.Result<ExtCore.AccountIdentifier, ExtCore.CommonError>;


    mintEventTickets: shared (request : MintTicketRequest) -> async ();
  };
};