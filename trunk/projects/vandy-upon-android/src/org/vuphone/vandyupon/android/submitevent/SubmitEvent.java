package org.vuphone.vandyupon.android.submitevent;

import java.io.IOException;
import java.util.Calendar;

import org.vuphone.vandyupon.android.LocationManager;
import org.vuphone.vandyupon.android.R;
import org.xmlpull.v1.XmlPullParserException;

import android.app.Activity;
import android.app.DatePickerDialog;
import android.app.Dialog;
import android.app.TimePickerDialog;
import android.content.Intent;
import android.content.res.ColorStateList;
import android.content.res.XmlResourceParser;
import android.os.Bundle;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.DatePicker;
import android.widget.EditText;
import android.widget.TextView;
import android.widget.TimePicker;
import android.widget.Toast;

import com.google.android.maps.GeoPoint;

/**
 * Allows a user to submit a new event to the main server
 * 
 * @author Hamilton Turner
 * 
 */
public class SubmitEvent extends Activity {
	protected static final int RESULT_OK = 0;
	protected static final int RESULT_UNKNOWN = 1;
	protected static final int RESULT_CANCELED = 2;
	protected static final String RESULT_NAME = "r";
	protected static final String RESULT_LAT = "lat";
	protected static final String RESULT_LNG = "lng";

	private static final int REQUEST_LIST_LOCATION = 0;
	private static final int REQUEST_MAP_LOCATION = 1;

	private static final int DIALOG_DATE_PICKER = 0;
	private static final int DIALOG_TIME_PICKER = 1;

	private TextView dateLabel_;
	private TextView timeLabel_;
	private TextView dateEndLabel_;
	private TextView timeEndLabel_;
	private TextView buildingLabel_;

	private int year_;
	private int month_;
	private int day_;
	private int hour_;
	private int minute_;
	
	private int endYear_;
	private int endMonth_;
	private int endDay_;
	private int endHour_;
	private int endMinute_;

	/**
	 * Keeps track of the lat and lng we will send to the server. Default to FGH
	 */
	private GeoPoint location_ = LocationManager.coordinates
			.get("Featheringill");

	/** Updates the text when the DatePicker dialog is set */
	private DatePickerDialog.OnDateSetListener dateSetListener_ = new DatePickerDialog.OnDateSetListener() {
		public void onDateSet(DatePicker view, int year, int monthOfYear,
				int dayOfMonth) {
			year_ = year;
			month_ = monthOfYear;
			day_ = dayOfMonth;
			updateDateLabels();
			dateLabel_.requestFocus();
		}
	};

	/** Updates the text when the TimePicker dialog is set */
	private TimePickerDialog.OnTimeSetListener timeSetListener_ = new TimePickerDialog.OnTimeSetListener() {
		public void onTimeSet(TimePicker view, int hourOfDay, int minute) {
			hour_ = hourOfDay;
			minute_ = minute;
			updateTimeLabels();
			timeLabel_.requestFocus();
		}
	};

	/** Clears the EditText fields. Used in the Menu */
	private void clear() {
		EditText et = (EditText) findViewById(R.id.ET_event_title);
		et.setText("");
		et = (EditText) findViewById(R.id.ET_event_desc);
		et.setText("");
	}

	/** Helper function to turn the Month from an integer into a String */
	private String convertMonth(int month) {
		switch (month) {
		case 0:
			return "Jan";
		case 1:
			return "Feb";
		case 2:
			return "Mar";
		case 3:
			return "Apr";
		case 4:
			return "May";
		case 5:
			return "June";
		case 6:
			return "July";
		case 7:
			return "Aug";
		case 8:
			return "Sept";
		case 9:
			return "Oct";
		case 10:
			return "Nov";
		case 11:
			return "Dec";
		default:
			return "Unknown";
		}
	}

	/**
	 * This method is called when the sending activity has finished, with the
	 * result it supplied.
	 * 
	 * @param requestCode
	 *            The original request code as given to startActivity().
	 * @param resultCode
	 *            From sending activity as per setResult().
	 * @param data
	 *            From sending activity as per setResult().
	 */
	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
		if (resultCode == RESULT_CANCELED)
			return;

		if (requestCode == REQUEST_LIST_LOCATION && resultCode == RESULT_OK) {
			buildingLabel_.setText(data.getStringExtra(RESULT_NAME));
			location_ = LocationManager.coordinates.get(data
					.getStringExtra(RESULT_NAME));
		} else if (requestCode == REQUEST_LIST_LOCATION
				&& resultCode == RESULT_UNKNOWN) {
			startActivityForResult(new Intent(this, LocationChooser.class),
					REQUEST_MAP_LOCATION);
		} else if (requestCode == REQUEST_MAP_LOCATION) {
			int lat = data.getIntExtra(RESULT_LAT, LocationManager.vandyCenter_
					.getLatitudeE6());
			int lng = data.getIntExtra(RESULT_LNG, LocationManager.vandyCenter_
					.getLongitudeE6());
			
			location_ = new GeoPoint(lat, lng);
			buildingLabel_.setText("Other");
		}

		// TODO - None of these will work right now, because the screen is in
		// touch mode. We don't want the controls to allow focus in touch mode,
		// because then you would have to double click them to activate them -
		// once to focus and once to click. So, we would like to figure out how
		// to change the mode of the screen here and then request focus
		buildingLabel_.requestFocus();
	}

	/** Called when the activity is first created. */
	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.submit_event);

		dateLabel_ = (TextView) findViewById(R.id.TV_event_date);
		timeLabel_ = (TextView) findViewById(R.id.TV_event_time);
		buildingLabel_ = (TextView) findViewById(R.id.TV_event_building);
		
		dateEndLabel_ = (TextView) findViewById(R.id.TV_event_date_end);
		timeEndLabel_ = (TextView) findViewById(R.id.TV_event_time_end);

		// Create the onClickListener for the date
		dateLabel_.setOnClickListener(new OnClickListener() {
			public void onClick(View v) {
				showDialog(DIALOG_DATE_PICKER);
			}
		});

		// Create the onClickListener for the date
		timeLabel_.setOnClickListener(new OnClickListener() {
			public void onClick(View v) {
				showDialog(DIALOG_TIME_PICKER);
			}
		});

		final Calendar c = Calendar.getInstance();

		// Set the initial date
		year_ = c.get(Calendar.YEAR);
		month_ = c.get(Calendar.MONTH);
		day_ = c.get(Calendar.DATE);
		hour_ = c.get(Calendar.HOUR_OF_DAY);
		minute_ = c.get(Calendar.MINUTE);
		endYear_ = year_;
		endMonth_ = month_;
		endDay_ = day_;
		endHour_ = (hour_ + 2) % 24;
		endMinute_ = minute_;
		
		updateDateLabels();
		updateTimeLabels();

		// Set up the location chooser
		buildingLabel_.setOnClickListener(new OnClickListener() {
			public void onClick(View v) {
				startActivityForResult(new Intent(SubmitEvent.this,
						ChooseLocation.class), REQUEST_LIST_LOCATION);
			}
		});

		ColorStateList csl = null;
		XmlResourceParser parser = getResources().getXml(
				R.color.focused_textview);
		try {
			csl = ColorStateList.createFromXml(getResources(), parser);
		} catch (XmlPullParserException e) {
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		}

		if (csl == null)
			return;

		dateLabel_.setTextColor(csl);
		timeLabel_.setTextColor(csl);
		buildingLabel_.setTextColor(csl);
		
		dateEndLabel_.setTextColor(csl);
		timeEndLabel_.setTextColor(csl);
	}

	/** Creates the menu items */
	public boolean onCreateOptionsMenu(Menu menu) {
		menu.add("Save");
		menu.add("Clear");
		return true;
	}

	/** Called when a dialog is first created */
	@Override
	protected Dialog onCreateDialog(int id) {
		switch (id) {
		case DIALOG_DATE_PICKER:
			return new DatePickerDialog(this, dateSetListener_, year_, month_,
					day_);
		case DIALOG_TIME_PICKER:
			return new TimePickerDialog(this, timeSetListener_, hour_, minute_,
					false);
		default:
			return null;
		}

	}

	/** Handles menu item selections */
	public boolean onOptionsItemSelected(MenuItem item) {
		if (item.getTitle().equals("Save")) {
			Toast.makeText(this, "Save", Toast.LENGTH_SHORT).show();
			Log.v("tag", "" + location_.getLatitudeE6() + ", "
					+ location_.getLongitudeE6());
		} else if (item.getTitle().equals("Clear"))
			clear();
		else
			return false;
		return true;
	}

	/** Called when a (created) dialog is about to be shown */
	@Override
	protected void onPrepareDialog(int id, Dialog dialog) {
		switch (id) {
		case DIALOG_DATE_PICKER:
			((DatePickerDialog) dialog).updateDate(year_, month_, day_);
			break;
		case DIALOG_TIME_PICKER:
			((TimePickerDialog) dialog).updateTime(hour_, minute_);
			break;
		}
	}

	/** Uses the current date variables to update the date text */
	private void updateDateLabels() {
		StringBuilder date = new StringBuilder(convertMonth(month_));
		date.append(". ");
		date.append(day_);
		date.append(", ");
		date.append(year_);
		dateLabel_.setText(date.toString());
		
		// Repeat process for end date
		date = new StringBuilder(convertMonth(endMonth_));
		date.append(". ");
		date.append(endDay_);
		date.append(", ");
		date.append(endYear_);
		dateEndLabel_.setText(date.toString());
	}

	/** Uses the current time variables to update the time text */
	private void updateTimeLabels() {
		int civilianHour = hour_;
		String amPm;

		if (civilianHour == 12)
			amPm = "PM";
		else if (civilianHour > 12) {
			civilianHour -= 12;
			amPm = "PM";
		} else {
			amPm = "AM";
		}

		// Correct for 0th hour
		if (civilianHour == 0)
			civilianHour = 12;

		StringBuilder time = new StringBuilder("" + civilianHour);
		time.append(":");
		if (minute_ < 10)
			time.append("0");
		time.append(minute_);
		time.append(" ");
		time.append(amPm);
		timeLabel_.setText(time.toString());
		
		// Repeat the entire process for the end time
		civilianHour = endHour_;

		if (civilianHour == 12)
			amPm = "PM";
		else if (civilianHour > 12) {
			civilianHour -= 12;
			amPm = "PM";
		} else {
			amPm = "AM";
		}

		// Correct for 0th hour
		if (civilianHour == 0)
			civilianHour = 12;

		time = new StringBuilder("" + civilianHour);
		time.append(":");
		if (endMinute_ < 10)
			time.append("0");
		time.append(endMinute_);
		time.append(" ");
		time.append(amPm);
		timeEndLabel_.setText(time.toString());
	}
}