package org.vuphone.vandyupon.notification.diningrating;

import java.io.UnsupportedEncodingException;

import javax.servlet.http.HttpServletRequest;

import org.vuphone.vandyupon.notification.Notification;
import org.vuphone.vandyupon.notification.NotificationParser;

public class DiningPostParser implements NotificationParser{

	@Override
	public Notification parse(HttpServletRequest req) {
		//Use UTF-8 Encoding <-- copied from EventPostParser
		try {
			req.setCharacterEncoding("UTF-8");
		} catch (UnsupportedEncodingException e) {
			e.printStackTrace();
		}
		
		//req.getParameter(); <--- this commands parse the stringline from device(i think? according to EventPostParser)
		
		//Check If the user is rating or requesting a rating.
		if(req.getParameter("type").equalsIgnoreCase("DiningRating"))
		{
			return new DiningRating(
					Integer.parseInt(req.getParameter("loc")),
					Integer.parseInt(req.getParameter("score")),
					req.getParameter("ID")
					);//Return a DiningPost object
		}
		else if(req.getParameter("type").equalsIgnoreCase("DiningRatingResponse"))
		{
			return new DiningRatingRequest(
					Integer.parseInt(req.getParameter("loc")),
					req.getParameter("ID")
					);//Return a DiningPost object
		}
		else //If the type is not dining as declared in constructor of DiningPost don't do anything
		{
			return null;
		}
	}
}