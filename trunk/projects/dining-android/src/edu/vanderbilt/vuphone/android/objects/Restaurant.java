package edu.vanderbilt.vuphone.android.objects;

import java.util.ArrayList;

import edu.vanderbilt.vuphone.android.dining.R;

public class Restaurant {
	
		
	private String _name;
	private RestaurantHours _hours;
	private Menu _menu;
	private String _description;
	private String _type;    // eg 'Cafe,' 'Mediterranian,' 'Coffee Shop'
	private int _icon;
	private int _latitude;
	private int _longitude;
	private boolean _favorite;
	private boolean _onTheCard;
	private boolean _offCampus; // taste of nashville
	private String _phoneNumber;
	private String _url;
	
	public Restaurant() {
		this(null);
	}
	public Restaurant(String name) {
		this(name, null, false);
	}
	public Restaurant(String name, RestaurantHours hours, boolean favorite) {
		this(name, hours, favorite, 0, 0, null, null, null, 0x0, true, false, null, null);
	}
	public Restaurant(String name, RestaurantHours hours, boolean favorite, int latitude, int longitude, String type, Menu menu,
			String description, int iconId, boolean onTheCard, boolean offCampus, String phoneNumber, String url) {
		setAttributes(name, hours, favorite, latitude, longitude, type, menu, description, iconId, onTheCard, offCampus, phoneNumber, url);
	}

	public boolean 			isOpen() 			{return _hours.isOpen();}
	public int 				minutesToOpen() 	{return _hours.minutesToOpen();}
	public int 				minutesToClose() 	{return _hours.minutesToClose();}
	public Time 			getNextOpenTime()	{return _hours.getNextOpenTime();}
	public Time 			getNextCloseTime()	{return _hours.getNextCloseTime();}
	
	// these methods may return null
	public String 			getName() 			{return _name;}
	public int 				getLat() 			{return _latitude;}
	public int 				getLon() 			{return _longitude;}
	public RestaurantHours 	getHours() 			{return _hours;}
	public String 			getDescription()	{return _description;}
	public String 			getType()			{return _type;}
	public Menu 			getMenu()			{return _menu;}
	public boolean 			favorite() 			{return _favorite;}
	public boolean			onTheCard()			{return _onTheCard;}
	public boolean			offCampus()			{return _offCampus;}
	public boolean			tasteOfNashville()	{return _onTheCard && _offCampus;}
	public String			getPhoneNumber()	{return _phoneNumber;}
	public String			getUrl()			{return _url;}
	public int				getIcon()			{return _icon;}

	
	// I made all the write methods protected so that Restaurants cannot be modified outside the objects package
	// not a completely ideal solution, but unauthorized writes to the restaurant cache must be prevented
	// to alter a Restaurant, use the static methods update() or setX() and then commit(). 
	protected void setAttributes(String name, RestaurantHours hours, boolean favorite, int latitude, int longitude, String type, Menu menu,
			String description, int iconId, boolean onTheCard, boolean offCampus, String phoneNumber, String url) {
		setName(name);
		setHours(hours);
		setFavorite(favorite);
		setLocation(latitude, longitude);
		setDescription(description);
		setType(type);
		setMenu(menu);
		setIcon(iconId);
		setOnTheCard(onTheCard);
		setOffCampus(offCampus);
		setPhoneNumber(phoneNumber);
		setUrl(url);
	}
	protected void setName(String name)				{_name = name;}
	protected void setHours(RestaurantHours hrs)	{_hours = hrs;}
	protected void setLatitude(int latitude)		{_latitude = latitude;}
	protected void setLongidute(int longitude)		{_longitude = longitude;}
	protected void setLocation(int lat, int lon)	{_latitude = lat; _longitude = lon;}
	protected void setFavorite(boolean fav) 		{_favorite = fav;}
	protected void setType(String type)				{_type = type;}
	protected void setMenu(Menu menu) 				{_menu = menu;}
	protected void setDescription(String desc)		{_description = desc;}
	protected void	setOnTheCard(boolean card)		{_onTheCard = card;}
	protected void	setOffCampus(boolean off)		{_offCampus = off;}
	protected void	setPhoneNumber(String number)	{_phoneNumber = number;}
	protected void setUrl(String url)				{_url = url;}
	protected void	setIcon(int iconID)				{_icon = iconID;}

	public boolean create() 						{return DBWrapper.create(this);}
	
	public String toString() {
		StringBuilder out = new StringBuilder();
		if (favorite())
			out.append("* ");
		out.append(getName()).append("  (").append(getLat()).append(",").append(getLon()).
			append(")\n").append(getDescription()).append("\n").append(getHours().toString());
		return out.toString();
	}
	
	// static methods for database access
	public static ArrayList<Long> getIDs() 					{return DBWrapper.getIDs();}
	public static Restaurant get(long rowID) 				{return DBWrapper.get(rowID);}
	public static String getName(long rowID) 				{return DBWrapper.getName(rowID);}
	public static int getLat(long rowID) 					{return DBWrapper.getLat(rowID);}
	public static int getLon(long rowID) 					{return DBWrapper.getLon(rowID);}
	public static RestaurantHours getHours(long rowID) 		{return DBWrapper.getHours(rowID);}
	public static String getType(long rowID)				{return DBWrapper.getType(rowID);}	
	public static int getIcon (Long rowID)					{return DBWrapper.getIcon(rowID);}
	public static boolean favorite(long rowID) 				{return DBWrapper.favorite(rowID);}
	public static boolean onTheCard(long rowID)				{return DBWrapper.onTheCard(rowID);}
	public static boolean offCampus(long rowID)				{return DBWrapper.offCampus(rowID);}
	
	public static boolean setFavorite(long rowID, boolean favorite) {return DBWrapper.setFavorite(rowID, favorite);}
	
	public static boolean commit() 							{return DBWrapper.commit();}
	public static void revert()								{DBWrapper.revert();}
	
	public static boolean create(Restaurant r) 				{return DBWrapper.create(r);}
	public static boolean update(long rowID, Restaurant r)	{return DBWrapper.update(rowID, r);}
	public static boolean delete(long rowID)				{return DBWrapper.delete(rowID);}
	
	// closes the underlying database. Use if no reads or writes are soon to be made
	public static void close()								{DBWrapper.close();}
}
