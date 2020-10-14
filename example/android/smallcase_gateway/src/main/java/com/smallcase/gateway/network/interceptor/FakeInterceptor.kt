package com.smallcase.gateway.network.interceptor

import com.smallcase.gateway.BuildConfig
import okhttp3.*
import java.io.IOException

class FakeInterceptor : Interceptor {
    @Throws(IOException::class)
    override fun intercept(chain: Interceptor.Chain): Response? {
        var response: Response? = null
        if (BuildConfig.DEBUG) {
           /* val responseString: String
            // Get Request URI.
            val uri: URI = chain.request().url().uri()
           *//* // Get Query String.
            val query: String = uri.getQuery()
            // Parse the Query String.
            val parsedQuery = query.split("=").toTypedArray()*//*
            responseString = if (parsedQuery[0].equals("id", ignoreCase = true) && parsedQuery[1]
                    .equals("1", ignoreCase = true)
            ) {
                TEACHER_ID_1
            } else if (parsedQuery[0].equals("id", ignoreCase = true) && parsedQuery[1]
                    .equals("2", ignoreCase = true)
            ) {
                TEACHER_ID_2
            } else {
                ""
            }*/
            response = Response.Builder()
                .code(200)
                .message(RESPONSE_JSON)
                .request(chain.request())
                .protocol(Protocol.HTTP_1_0)
                .body(
                    ResponseBody.create(
                        MediaType.parse("application/json"),
                        RESPONSE_JSON.toByteArray()
                    )
                )
                .addHeader("content-type", "application/json")
                .build()
        } else {
            response = chain.proceed(chain.request())
        }
        return response
    }

    companion object {
        // FAKE RESPONSES.
        private const val RESPONSE_JSON = "[\n" +
                "    {\n" +
                "        \"broker\": \"fivepaisa\",\n" +
                "        \"brokerDisplayName\": \"5paisa\",\n" +
                "        \"brokerShortName\": \"5paisa\",\n" +
                "        \"platformURL\": \"https://smallcases.5paisa.com\",\n" +
                "        \"leprechaunURL\": \"https://smallcases.5paisa.com\",\n" +
                "        \"baseLoginURL\": \"https://www.5paisa.com/vlogin-page?vid=smcs\",\n" +
                "        \"accountOpeningURL\": \"https://www.5paisa.com/open-demat-account\",\n" +
                "        \"isRedirectURL\": false,\n" +
                "        \"trustedBroker\": true,\n" +
                "        \"isIframePlatform\": false,\n" +
                "        \"visible\": true,\n" +
                "        \"topBroker\": true,\n" +
                "        \"popularity\": 5,\n" +
                "        \"gatewayVisible\": true\n" +
                "    },\n" +
                "    {\n" +
                "        \"broker\": \"aliceblue\",\n" +
                "        \"brokerDisplayName\": \"Alice Blue\",\n" +
                "        \"brokerShortName\": \"Alice Blue\",\n" +
                "        \"platformURL\": \"https://smallcases.aliceblueonline.com\",\n" +
                "        \"leprechaunURL\": \"https://smallcases.aliceblueonline.com\",\n" +
                "        \"baseLoginURL\": \"https://ant.aliceblueonline.com/oauth2/auth?client_id=SMALLCASE&redirect_uri=https%3A%2F%2Fsmallcases.aliceblueonline.com%2FbrokerLogin&response_type=code\",\n" +
                "        \"accountOpeningURL\": \"http://app.aliceblueonline.com/OpenAccount.aspx\",\n" +
                "        \"isRedirectURL\": true,\n" +
                "        \"trustedBroker\": true,\n" +
                "        \"isIframePlatform\": false,\n" +
                "        \"visible\": true,\n" +
                "        \"topBroker\": false,\n" +
                "        \"popularity\": 8,\n" +
                "        \"gatewayVisible\": true\n" +
                "    },\n" +
                "    {\n" +
                "        \"broker\": \"axis\",\n" +
                "        \"brokerDisplayName\": \"AxisDirect\",\n" +
                "        \"brokerShortName\": \"AxisDirect\",\n" +
                "        \"platformURL\": \"https://simplehai.axisdirect.in/app/index.php/smallcase/redirect\",\n" +
                "        \"leprechaunURL\": \"https://axisdirect.smallcase.com\",\n" +
                "        \"baseLoginURL\": \"https://simplehai.axisdirect.in/app/index.php/smallcase/redirect?\",\n" +
                "        \"accountOpeningURL\": \"https://simplehai.axisdirect.in/open-account\",\n" +
                "        \"isRedirectURL\": true,\n" +
                "        \"trustedBroker\": true,\n" +
                "        \"isIframePlatform\": true,\n" +
                "        \"visible\": true,\n" +
                "        \"topBroker\": true,\n" +
                "        \"popularity\": 1,\n" +
                "        \"gatewayVisible\": false,\n" +
                "        \"consentStr\": \"I hereby agree to be redirected to <style>Axis Securities's</style> trading website.I hereby authorise <style>Axis Securities</style>, to share details of scrip, traded quantity and trade price of transactions executed pursuant to this redirection with <style>smartinvesting</style>\"\n" +
                "    },\n" +
                "    {\n" +
                "        \"broker\": \"edelweiss\",\n" +
                "        \"brokerDisplayName\": \"Edelweiss\",\n" +
                "        \"brokerShortName\": \"Edelweiss\",\n" +
                "        \"platformURL\": \"https://smallcases.edelweiss.in\",\n" +
                "        \"leprechaunURL\": \"https://smallcases.edelweiss.in\",\n" +
                "        \"baseLoginURL\": \"https://www.edelweiss.in/vlogin/smallcase?\",\n" +
                "        \"accountOpeningURL\": \"https://www.edelweiss.in/cas/microsite/acquisition-lp/free-demat-account-special-offer.html\",\n" +
                "        \"isRedirectURL\": true,\n" +
                "        \"trustedBroker\": true,\n" +
                "        \"isIframePlatform\": false,\n" +
                "        \"visible\": true,\n" +
                "        \"topBroker\": false,\n" +
                "        \"popularity\": 7,\n" +
                "        \"gatewayVisible\": true\n" +
                "    },\n" +
                "    {\n" +
                "        \"broker\": \"hdfc\",\n" +
                "        \"brokerDisplayName\": \"HDFC Securities\",\n" +
                "        \"brokerShortName\": \"HDFC Sec\",\n" +
                "        \"platformURL\": \"https://deepors.hdfcsec.com/smallcase/index\",\n" +
                "        \"leprechaunURL\": \"https://hdfc.smallcase.com\",\n" +
                "        \"baseLoginURL\": \"https://deepors.hdfcsec.com/smallcase/index?\",\n" +
                "        \"accountOpeningURL\": \"https://www.hdfcsec.com/open-trading-ac\",\n" +
                "        \"isRedirectURL\": true,\n" +
                "        \"trustedBroker\": true,\n" +
                "        \"isIframePlatform\": true,\n" +
                "        \"visible\": true,\n" +
                "        \"topBroker\": true,\n" +
                "        \"popularity\": 2,\n" +
                "        \"gatewayVisible\": true\n" +
                "    },\n" +
                "    {\n" +
                "        \"broker\": \"hdfcpbg\",\n" +
                "        \"brokerDisplayName\": \"HDFC Securities\",\n" +
                "        \"brokerShortName\": \"HDFC Sec\",\n" +
                "        \"platformURL\": \"https://einvest.hdfcsec.com/einvest/index\",\n" +
                "        \"leprechaunURL\": \"https://hdfcpbg.smallcase.com\",\n" +
                "        \"baseLoginURL\": \"https://einvest.hdfcsec.com/einvest/index?\",\n" +
                "        \"accountOpeningURL\": \"https://www.hdfcsec.com/open-trading-ac\",\n" +
                "        \"isRedirectURL\": true,\n" +
                "        \"trustedBroker\": false,\n" +
                "        \"isIframePlatform\": true,\n" +
                "        \"visible\": false,\n" +
                "        \"topBroker\": false,\n" +
                "        \"popularity\": 10000,\n" +
                "        \"gatewayVisible\": false\n" +
                "    },\n" +
                "    {\n" +
                "        \"broker\": \"iifl\",\n" +
                "        \"brokerDisplayName\": \"IIFL Securities\",\n" +
                "        \"brokerShortName\": \"IIFL Sec\",\n" +
                "        \"platformURL\": \"https://smallcases.indiainfoline.com\",\n" +
                "        \"leprechaunURL\": \"https://smallcases.indiainfoline.com\",\n" +
                "        \"baseLoginURL\": \"https://ttweb.indiainfoline.com/Trade/Login.aspx?\",\n" +
                "        \"accountOpeningURL\": \"https://eaccount.indiainfoline.com\",\n" +
                "        \"isRedirectURL\": true,\n" +
                "        \"trustedBroker\": true,\n" +
                "        \"isIframePlatform\": false,\n" +
                "        \"visible\": true,\n" +
                "        \"topBroker\": true,\n" +
                "        \"popularity\": 6,\n" +
                "        \"gatewayVisible\": true\n" +
                "    },\n" +
                "    {\n" +
                "        \"broker\": \"kotak\",\n" +
                "        \"brokerDisplayName\": \"Kotak Securities\",\n" +
                "        \"brokerShortName\": \"Kotak Sec\",\n" +
                "        \"platformURL\": \"https://smallcase.kotaksecurities.com\",\n" +
                "        \"leprechaunURL\": \"https://smallcase.kotaksecurities.com\",\n" +
                "        \"baseLoginURL\": \"https://www.kotaksecurities.com/itrade/user/marketing.exe?action=redsc\",\n" +
                "        \"accountOpeningURL\": \"https://www.kotaksecurities.com/\",\n" +
                "        \"isRedirectURL\": true,\n" +
                "        \"trustedBroker\": true,\n" +
                "        \"isIframePlatform\": false,\n" +
                "        \"visible\": true,\n" +
                "        \"topBroker\": true,\n" +
                "        \"popularity\": 3,\n" +
                "        \"gatewayVisible\": false\n" +
                "    },\n" +
                "    {\n" +
                "        \"broker\": \"trustline\",\n" +
                "        \"brokerDisplayName\": \"Trustline\",\n" +
                "        \"brokerShortName\": \"Trustline\",\n" +
                "        \"platformURL\": \"https://smallcases.trustline.in\",\n" +
                "        \"leprechaunURL\": \"https://smallcases.trustline.in\",\n" +
                "        \"baseLoginURL\": \"https://itrade-beta.trustline.in/oauth2/auth?scope=orders%20holdings&client_id=SMALLCASE&redirect_uri=https%3A%2F%2Fsmallcases.trustline.in%2FbrokerLogin&response_type=code\",\n" +
                "        \"accountOpeningURL\": \"https://www.trustline.in/contact\",\n" +
                "        \"isRedirectURL\": false,\n" +
                "        \"trustedBroker\": false,\n" +
                "        \"isIframePlatform\": false,\n" +
                "        \"visible\": true,\n" +
                "        \"topBroker\": false,\n" +
                "        \"popularity\": 9,\n" +
                "        \"gatewayVisible\": true\n" +
                "    },\n" +
                "    {\n" +
                "        \"broker\": \"kite\",\n" +
                "        \"brokerDisplayName\": \"Zerodha\",\n" +
                "        \"brokerShortName\": \"Zerodha\",\n" +
                "        \"platformURL\": \"https://smallcase.zerodha.com\",\n" +
                "        \"leprechaunURL\": \"https://smallcase.zerodha.com\",\n" +
                "        \"baseLoginURL\": \"https://kite.zerodha.com/connect/login?api_key=12hpqpbfwnxyvud8\",\n" +
                "        \"accountOpeningURL\": \"https://zerodha.com/open-account\",\n" +
                "        \"isRedirectURL\": false,\n" +
                "        \"trustedBroker\": true,\n" +
                "        \"isIframePlatform\": false,\n" +
                "        \"visible\": true,\n" +
                "        \"topBroker\": true,\n" +
                "        \"popularity\": 4,\n" +
                "        \"gatewayVisible\": true\n" +
                "    }\n" +
                "]"

    }
}