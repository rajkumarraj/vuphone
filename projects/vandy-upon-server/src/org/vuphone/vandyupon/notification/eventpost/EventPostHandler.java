/**************************************************************************
 * Copyright 2009 Chris Thompson                                           *
 *                                                                         *
 * Licensed under the Apache License, Version 2.0 (the "License");         *
 * you may not use this file except in compliance with the License.        *
 * You may obtain a copy of the License at                                 *
 *                                                                         *
 * http://www.apache.org/licenses/LICENSE-2.0                              *
 *                                                                         *
 * Unless required by applicable law or agreed to in writing, software     *
 * distributed under the License is distributed on an "AS IS" BASIS,       *
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.*
 * See the License for the specific language governing permissions and     *
 * limitations under the License.                                          *
 **************************************************************************/
package org.vuphone.vandyupon.notification.eventpost;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import javax.sql.DataSource;

import org.vuphone.vandyupon.notification.HandlerFailedException;
import org.vuphone.vandyupon.notification.InvalidFormatException;
import org.vuphone.vandyupon.notification.Notification;
import org.vuphone.vandyupon.notification.NotificationHandler;

public class EventPostHandler implements NotificationHandler {

	private DataSource ds_;
	
	/**
	 * Helper method that generates an event entry in the database and returns
	 * the index of the newly created event.
	 * @param ep
	 * @param locationId
	 * @return
	 * @throws SQLException
	 */
	private int createEvent(EventPost ep, int locationId) throws SQLException{
		Connection conn = ds_.getConnection();
		String sql = "insert into events (name, locationid, userid) values (?, ?, ?)";
		PreparedStatement prep = conn.prepareStatement(sql);
		prep.setString(1, ep.getName());
		prep.setInt(2, locationId);
		prep.setInt(3, ep.getUser());
		
		if (prep.executeUpdate() == 0){
			throw new SQLException("Insertion into vandyupon.events failed for an unknown reason");
		}else{
			//Everything worked
			return prep.getGeneratedKeys().getInt(1);
		}
	}

	@Override
	public Notification handle(Notification n) throws HandlerFailedException {

		if (!(n instanceof EventPost)){
			HandlerFailedException hfe = new HandlerFailedException();
			hfe.initCause(new InvalidFormatException());
			throw hfe;
		}

		EventPost ep = (EventPost) n;
		try{
			if (verifyUserID(ep)){
				int locationid = getLocationId(ep);
				return new EventPostHandled(createEvent(ep, locationid));
			}
		}catch (SQLException e){
			e.printStackTrace();
		}

		return null;
	}

	public DataSource getDataConnection(){
		return ds_;
	}

	/**
	 * Private helper method that accesses the database to return the id of the location
	 * at a given point.  If no location is currently at that point a new one is created.
	 * @return
	 */
	private int getLocationId(EventPost ep) throws SQLException{
		String sql;
		Connection conn;
		conn = ds_.getConnection();
		sql = "select * from locations where lat = ? and lon = ?";
		PreparedStatement prep = conn.prepareStatement(sql);
		prep.setDouble(1, ep.getLocation().getLat());
		prep.setDouble(2, ep.getLocation().getLon());

		ResultSet rs = prep.executeQuery();
		rs.next();
		int id = rs.getInt("locationid");

		if (id == 0){
			sql = "insert into locations (name, lat, lon, userid) values (?, ?, ?, ?)";
			prep.setString(1, ep.getName());
			prep.setDouble(2, ep.getLocation().getLat());
			prep.setDouble(3, ep.getLocation().getLon());
			prep.setInt(4, ep.getUser());

			prep.execute();
			id = prep.getGeneratedKeys().getInt(1);
		}
		return id;

	}

	public void setDataConnection(DataSource ds){
		ds_ = ds;
	}

	/**
	 * This helper method is designed to check the validity of the user id submitted with the
	 * event.
	 * @param ep - The event post object
	 * @return boolean - Whether the id is a valid user or not
	 * @throws SQLException
	 */
	private boolean verifyUserID(EventPost ep) throws SQLException{
		String sql;
		Connection conn = ds_.getConnection();
		sql = "select * from people where userid = ?";
		PreparedStatement prep = conn.prepareStatement(sql);
		prep.setInt(1, ep.getUser());
		ResultSet rs = prep.executeQuery();
		rs.next();
		if (rs.getInt(1) != 0){
			return true;
		}else{
			return false;
		}
	}



}