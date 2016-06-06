public with sharing class X_Email {

	public static X.Response send(List<String> to, List<String> cc, List<String> bcc, String replyTo, String senderDisplayName, String subject, String htmlBody, String body, List<Attachment> attachments) {
		try {
			Messaging.reserveSingleEmailCapacity(1);
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

			mail.setToAddresses(to);
			mail.setCcAddresses(cc);
			mail.setBccAddresses(bcc);
			mail.setReplyTo(replyTo);
			mail.setSenderDisplayName(senderDisplayName);
			mail.setSubject(subject);
			mail.setBccSender(false);
			mail.setUseSignature(false);
			mail.setPlainTextBody(body);
			mail.setHtmlBody(htmlbody);

			if (attachments != null && attachments.size() > 0) {
				List<Messaging.EmailFileAttachment> efas = new List<Messaging.EmailFileAttachment>();
				for (Attachment a : attachments) {
					Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
					efa.setFileName(a.Name);
					efa.setBody(a.Body);
					efas.add(efa);
				}
				mail.setFileAttachments(efas);
			}

			Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{mail});
			return new X.Response(true);
		} catch (Exception e) {
			return new X.Response(false, new List<X.Error>{new X.Error('INTERNAL_ERROR', e.getMessage(), e.getStackTraceString())});
		}
	}
}