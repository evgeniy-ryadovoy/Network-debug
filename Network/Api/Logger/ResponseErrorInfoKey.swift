public enum ResponseErrorInfoKey {
    static let apiMethod = "API method"
    static let errorDescription = "Error Description"
    static let requestURLPath = "Request URL Path"
    static let responseObjectUserInfoKey = "ResponseObject"
    static let responseDataUserInfoKey = "ResponseData"
    static let responseDecoderUserInfoKey = "ResponseDecoderInfo"
    static let responseDecoderReasonKey = "ResponseDecoderReason"

    // special param for grouping events
    public static let fingerprint = "fingerprint"
}
