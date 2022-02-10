// 3rd Party Imports

import Array "mo:base/Array";
import Blob "mo:base/Blob";
import Cycles "mo:base/ExperimentalCycles";
// import Ext "mo:ext/Ext";
import Float "mo:base/Float";
import Iter "mo:base/Iter";
import Nat "mo:base/Nat";
import Int "mo:base/Int";
import Nat8 "mo:base/Nat8";
import Nat32 "mo:base/Nat32";
import Nat64 "mo:base/Nat64";
import Prim "mo:prim";
import Principal "mo:base/Principal";
import Text "mo:base/Text";

import ExtCore "../motoko/ext/Core";
import NFTicket "../ticket/NFTicket";
import CDN "../asset/Types";
import Types "types";



module {

    public class HttpHandler () {

        private func getContentType(ext: CDN.FileExtension): Text{
        
            switch(ext) {
                case(#jpeg){
                    "image/jpeg"
                };
                case(#gif){
                    "image/gif"
                };
                case(#jpg){
                    "image/jpg"
                };                                
                case(#png){
                    "image/png"
                };                
                case(#svg){
                    "image/svg"
                };
                case(#avi){
                    "video/avi"
                };
                case(#mp4){
                    "video/mp4"
                };
                case(#aac){
                    "video/aac"
                };
                case(#wav){
                    "audio/wav"
                };
                case(#mp3){
                    "audio/mp3"
                }; 
                case(_){
                    "text/plain"
                }                                                                                               
            };
        };

        // Craft an HTTP response from an Asset Record.
        private func renderAsset (
            
        ) : Types.Response {
            {
                body = Blob.fromArray([]);//state.assets._flattenPayload(asset.asset.payload);
                headers = [
                    ("Content-Type", ""),
                    ("Access-Control-Allow-Origin", "*"),
                ];
                status_code = 200;
                streaming_strategy = null;
            }
        };



   

        ////////////////////
        // Path Handlers //
        //////////////////



        // @path: *?tokenid

        public func httpIndex(request : Types.Request) : Types.Response {
            //let tokenId = Iter.toArray(Text.tokens(request.url, #text("tokenid=")))[1];
            // let { index } = Stoic.decodeToken(tokenId);

                // let path = Iter.toArray(Text.tokens(request.url, #text("/")));
               
                return {
                    status_code = 200;
                    headers = [("content-type", "text/plain")];
                    body = Text.encodeUtf8 (
                        "ICEvent NFTicket" # "\n" 
                    );
                    streaming_strategy = null;
                };

        };


        
        public func renderTicket(tokenIndex: Nat32, ticket: NFTicket.Metadata): Types.Response {

                return {
                    status_code = 200;
                    headers = [("content-type", "image/svg+xml")];
                    body = Text.encodeUtf8 (
                         
                        "<svg xmlns=\"http://www.w3.org/2000/svg\" preserveAspectRatio=\"xMinYMin meet\" viewBox=\"0 0 500 500\">"#
                            "<style>" #
                            ".base { fill: white; font-family: HelveticaNeue-Bold, Helvetica Neue; font-size: 14px; } " #
                            ".title {fill: white; font-family:HelveticaNeue-Bold, Helvetica Neue; font-size: 20px;}" #
                            "</style>" #
                            "<rect width=\"100%\" height=\"100%\"/>" #
                            "<text x=\"10\" y=\"20\" class=\"title\">" #
                            "ICEvent Ticket  #" # Nat32.toText(tokenIndex)  #
                            "</text>" #
                            "<text x=\"10\" y=\"40\" class=\"base\">" #
                            
                            "</text>" #
                            "<text x=\"10\" y=\"60\" class=\"base\">" #
                            "Event: " #  ticket.event_name #
                            "</text>" #
                            "<text x=\"10\" y=\"80\" class=\"base\">" #
                            "Time: "# ticket.event_day #
                            "</text>" #
                            "<text x=\"10\" y=\"100\" class=\"base\">" #
                            "Location: " # ticket.event_location #
                            "</text>" #
                            "<text x=\"10\" y=\"120\" class=\"base\">" #
                            "Host: "# ticket.host #
                            "</text>  " #                  
                        "</svg>" 
                    );
                    streaming_strategy = null;
                };

        };

      
        public func renderMesssage(message: Text): Types.Response{
                return {
                    status_code = 200;
                    headers = [("content-type", "text/plain")];
                    body = Text.encodeUtf8 (
                        message
                    );
                    streaming_strategy = null;
                };
        };
   


        // A 404 response with an optional error message.
        private func http404(msg : ?Text) : Types.Response {
            {
                body = Text.encodeUtf8(
                    switch (msg) {
                        case (?msg) msg;
                        case null "Not found.";
                    }
                );
                headers = [
                    ("Content-Type", "text/plain"),
                ];
                status_code = 404;
                streaming_strategy = null;
            };
        };


        // A 400 response with an optional error message.
        private func http400(msg : ?Text) : Types.Response {
            {
                body = Text.encodeUtf8(
                    switch (msg) {
                        case (?msg) msg;
                        case null "Bad request.";
                    }
                );
                headers = [
                    ("Content-Type", "text/plain"),
                ];
                status_code = 400;
                streaming_strategy = null;
            };
        };



        public func request(request : Types.Request) : Types.Response {
            

            // if (Text.contains(request.url, #text("tokenid"))) {
            //     let tokenId = Iter.toArray(Text.tokens(request.url, #text("tokenid=")))[1];
            //     let tokenind = ExtCore.TokenIdentifier.getIndex(tokenId);
            //     return renderTicket("text/plain", Text.encodeUtf8 ("ICEvent NFTicket" # "\n"  ));
            // }else{
                return httpIndex(request);
            // }

            

            // Paths

            //let path = Iter.toArray(Text.tokens(request.url, #text("/")));


            // 404

            
        };
    };
};