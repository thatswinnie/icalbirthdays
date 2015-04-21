This Automator Action creates a birthday calendar in iCal from the contacts in Address Book. Unlike the built-in birthday calendar in iCal, this action allows you to set an alarm for each birthday.

![http://www.thatswinnie.com/img/icalbirthdays_screenshot_2_0_en.jpg](http://www.thatswinnie.com/img/icalbirthdays_screenshot_2_0_en.jpg)

If you want to customize your event or reminder text you can use the following placeholders:
  * %lastname%
  * %firstname%
  * %yearofbirth%
  * %age%
  * %birthday%

<wiki:gadget url="http://stefansundin.com/stuff/flattr/google-project-hosting.xml" border="0" width="120" height="20" up\_button="compact" up\_uid="17796" up\_title="iCalBirthdays" up\_desc="This Automator Action creates a birthday calendar in iCal from the contacts in Address Book. Unlike the built-in birthday calendar in iCal, this action allows you to set an alarm for each birthday." up\_tags="icalbirthdays,automator,mac os x,ical,addressbook,birthdays,calendar,alert" up\_url="http://code.google.com/p/icalbirthdays/" /> [![](https://www.paypal.com/en_US/i/btn/x-click-but04.gif)](http://www.thatswinnie.com/donate-spenden/)

**Changelog**

_2.0.1_
  * bugfix of switched alarm options in german version

_2.0_
  * completely rewritten in Cocoa
  * possible to filter for people and groups as prepended Automator Action ([issue 16](https://code.google.com/p/icalbirthdays/issues/detail?id=16))
  * calendars for current and next year ([issue 8](https://code.google.com/p/icalbirthdays/issues/detail?id=8))
  * email reminder ([issue 9](https://code.google.com/p/icalbirthdays/issues/detail?id=9))
  * events since birth
  * error in custom formats fixed ([issue 21](https://code.google.com/p/icalbirthdays/issues/detail?id=21), [issue 22](https://code.google.com/p/icalbirthdays/issues/detail?id=22), [issue 28](https://code.google.com/p/icalbirthdays/issues/detail?id=28), [issue 29](https://code.google.com/p/icalbirthdays/issues/detail?id=29))
  * removed the calendar export option

_1.7.1_
  * fixed Snow Leopard issue ([issue 20](https://code.google.com/p/icalbirthdays/issues/detail?id=20))

_1.7_
  * fixed 12 AM issue ([issue 5](https://code.google.com/p/icalbirthdays/issues/detail?id=5))
  * fixed problems with some time zones
  * alerts for birthdays on the day iCalBirthdays is run
  * removed titles and middle names

_1.6_
  * made the export optional
  * added event type for choosing all day events or event at alert time
  * made alert sound optional
  * added more formats for alert text
  * made alert text customizable
  * added alternative text for reminder
  * added a cake icon for the action

_1.5_
  * added customizable calendar entry format
  * removed / replaced age with year of birth

_1.4_
  * Localization for German added
  * Age added

_1.3_
  * changed the export of calendar for leopard
  * additional alert is actually added to the birthday event (instead of creating another event)
  * choice of which alert to enable

_1.2_
  * solved errors in Tiger

_1.1_
  * Leopard ready
  * optional additional alert before the birthday