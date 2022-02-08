// This is a generated Motoko binding.
// Please use `import service "ic:canister_id"` instead to call canisters on the IC if possible.

module {
  public type FileData = {
    cid : Principal;
    owner : Principal;
    name : Text;
    createdAt : Timestamp;
    size : Nat;
    fileId : FileId__1;
    chunkCount : Nat;
    extension : FileExtension;
    uploadedAt : Timestamp;
  };
  public type FileExtension = {
    #aac;
    #avi;
    #gif;
    #jpg;
    #mp3;
    #mp4;
    #png;
    #svg;
    #wav;
    #jpeg;
  };
  public type FileId = Text;
  public type FileId__1 = Text;
  public type FileInfo = {
    owner : Principal;
    name : Text;
    createdAt : Timestamp;
    size : Nat;
    chunkCount : Nat;
    extension : FileExtension;
  };
  public type Result = { #ok : Nat; #err : Text };
  public type Result_1 = { #ok : FileId; #err : Text };
  public type Timestamp = Int;
  public type Uploader = {
    files : [FileId__1];
    quota : Nat;
    uploader : Principal;
  };
  public type Self = actor {
    addModerator : shared Principal -> async ();
    availableCycles : shared query () -> async Nat;
    fetchFileChunk : shared (FileId, Nat) -> async ?[Nat8];
    fetchFileChunks : shared FileId -> async ?[Nat8];
    fetchFileInfo : shared FileId -> async ?FileData;
    getAdmin : shared query () -> async Principal;
    getFileChunk : shared (FileId, Nat) -> async ?[Nat8];
    getFileInfo : shared FileId -> async ?FileData;
    getModerators : shared query () -> async [Principal];
    getStatus : shared query () -> async [(Principal, Nat)];
    getUploaders : shared query () -> async [Uploader];
    putFileChunks : shared (FileId, Nat, Nat, [Nat8]) -> async Result;
    putFileInfo : shared FileInfo -> async Result_1;
    saveFileChunks : shared (FileId, Nat, Nat, [Nat8]) -> async Result;
    setAdmin : shared Principal -> async ();
    setUploaders : shared (Principal, Nat) -> async Result;
    updateStatus : shared () -> async ();
    wallet_receive : shared () -> async ();
  }
}