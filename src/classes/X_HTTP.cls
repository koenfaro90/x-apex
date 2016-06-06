public class X_HTTP {
	public class Response {
		public HttpResponse rawResponse;
		public String body;
		public Integer statusCode;
		public Boolean success;
		public String errorMessage;
		public Exception error;
	}

	public static Response send(String endpoint, String method, String body, Map<String,String> headers) {
		Response result = new Response();

		Http httpObj = new Http();
		HttpRequest req = new HttpRequest();

		req.setEndpoint(endpoint);
		for (String s : headers.keySet()) {
			req.setHeader(s,headers.get(s));
		}
		req.setMethod(method);
		req.setBody(body);

		HttpResponse response = null;
		try {
			response = httpObj.send(req);
			result.success = true;
			result.statusCode = response.getStatusCode();
			result.body = response.getBody();
			result.rawResponse = response;
		} catch (Exception e) {
			result.success = false;
			result.errorMessage = e.getMessage();
			result.error = e;
		}
		return result;
	}
}