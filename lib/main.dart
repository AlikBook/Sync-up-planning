import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:planning/main_classes.dart';
import 'package:planning/pages/settings_page.dart';
import 'package:planning/pages/events_list_page.dart';
import 'package:planning/pages/person_details_page.dart';

import 'my_form.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SyncUp',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue),
        primarySwatch: Colors.blue,
        appBarTheme: AppBarTheme(backgroundColor: Colors.lightBlue, foregroundColor: Colors.white),
      ),
      // Define routes
      initialRoute: '/',
      routes: {
        '/': (context) => const MyHomePage(title: 'Event Planning App'),
        '/settings': (context) => SettingsPage(),
        '/events': (context) => EventsListPage(),
        '/persons': (context) => PersonDetailsPage(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  List<Event> _getEventsForDay(DateTime day) {
    return list_of_events.where((event) {
      //runs through each element of the list and sees if the day is the same
      return isSameDay(event.event_date, day);
    }).toList();
  }

  // Method to get the attendance status color for a day
  Color _getDayAttendanceColor(DateTime day) {
    final dayEvents = _getEventsForDay(day);
    if (dayEvents.isEmpty) return Colors.grey[300]!; // No events

    bool hasAbsent = false;
    bool hasUndefined = false;
    bool hasParticipants = false;

    for (final event in dayEvents) {
      if (event.event_participants.isNotEmpty) {
        hasParticipants = true;
        for (final participant in event.event_participants) {
          if (participant.$2 == "Absent") {
            hasAbsent = true;
          } else if (participant.$2 == "No status") {
            hasUndefined = true;
          }
        }
      }
    }

    if (!hasParticipants) return Colors.grey[300]!;

    if (hasAbsent) return Colors.red[300]!;
    if (hasUndefined) return const Color.fromARGB(255, 88, 88, 88);
    return Colors.green[300]!;
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case "Present":
        return Colors.green;
      case "Absent":
        return Colors.red;
      case "Not defined":
      default:
        return Colors.grey;
    }
  }

  void _updateParticipantStatus(Event event, Person person, String newStatus, String prev_status) {
    setState(() {
      for (int i = 0; i < event.event_participants.length; i++) {
        if (event.event_participants[i].$1 == person) {
          event.event_participants[i] = (person, newStatus);
          break;
        }
      }

      for (int i = 0; i < person.events_participated.length; i++) {
        if (person.events_participated[i].$1 == event) {
          person.events_participated[i] = (event, newStatus);
          if (newStatus == "Absent") {
            person.n_abcenses++;
          }
          if (prev_status == "Absent" && newStatus == "Present") {
            person.n_abcenses--;
          }
          break;
        }
      }
    });
  }

  String _getMonthName(int month) {
    const monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return monthNames[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlue,
        title: Text(
          "Planning Manager",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.list, color: Colors.white),
            onPressed: () {
              Navigator.pushNamed(context, '/events');
            },
            tooltip: 'View All Events',
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: ElevatedButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/persons'),
              icon: Icon(Icons.person, size: 18),
              label: Text("Persons"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.lightBlue,
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
            tooltip: 'Settings',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(30),
          decoration: BoxDecoration(color: const Color.fromARGB(255, 209, 209, 209)),
          child: LayoutBuilder(
            builder: (context, constraints) {
              bool isLargeScreen = constraints.maxWidth > 1000;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  isLargeScreen
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Left side: Calendar and Events (takes 65% of width)
                            Expanded(
                              flex: 65,
                              child: Column(
                                children: [
                                  // Calendar section
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.2),
                                          spreadRadius: 3,
                                          blurRadius: 10,
                                          offset: Offset(0, 5),
                                        ),
                                      ],
                                    ),
                                    margin: EdgeInsets.only(bottom: 20),
                                    padding: EdgeInsets.all(16),
                                    child: TableCalendar<Event>(
                                      firstDay: DateTime.utc(2020, 1, 1),
                                      lastDay: DateTime.utc(2030, 12, 31),
                                      focusedDay: _focusedDay,
                                      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                                      //updates the selected day on selection in the UI
                                      onDaySelected: (selectedDay, focusedDay) {
                                        setState(() {
                                          _selectedDay = selectedDay;
                                          _focusedDay = focusedDay;
                                        });
                                      },
                                      headerStyle: HeaderStyle(
                                        formatButtonVisible: false,
                                        titleCentered: true,
                                        titleTextStyle: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.lightBlue,
                                        ),
                                        leftChevronIcon: Icon(Icons.chevron_left, color: Colors.lightBlue),
                                        rightChevronIcon: Icon(Icons.chevron_right, color: Colors.lightBlue),
                                      ),
                                      daysOfWeekStyle: DaysOfWeekStyle(
                                        weekdayStyle: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w600),
                                        weekendStyle: TextStyle(
                                          color: Colors.lightBlue[300],
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      calendarStyle: CalendarStyle(
                                        outsideDaysVisible: false,
                                        todayDecoration: BoxDecoration(color: Colors.black, shape: BoxShape.circle),
                                        selectedDecoration: BoxDecoration(
                                          color: Colors.lightBlue,
                                          shape: BoxShape.circle,
                                        ),
                                        weekendTextStyle: TextStyle(color: Colors.lightBlue[400]),
                                        holidayTextStyle: TextStyle(color: Colors.red[400]),
                                      ),
                                      calendarBuilders: CalendarBuilders(
                                        defaultBuilder: (context, day, focusedDay) {
                                          final dayEvents = _getEventsForDay(day);
                                          if (dayEvents.isNotEmpty) {
                                            final attendanceColor = _getDayAttendanceColor(day);
                                            return Container(
                                              margin: const EdgeInsets.all(4.0),
                                              decoration: BoxDecoration(
                                                color: attendanceColor,
                                                shape: BoxShape.circle,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: attendanceColor.withOpacity(0.4),
                                                    spreadRadius: 1,
                                                    blurRadius: 3,
                                                    offset: Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              alignment: Alignment.center,
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    '${day.day}',
                                                    style: TextStyle(
                                                      color: attendanceColor == Colors.grey[300]
                                                          ? Colors.black87
                                                          : Colors.white,
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                  Container(
                                                    margin: EdgeInsets.only(top: 2),
                                                    width: 6,
                                                    height: 6,
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      shape: BoxShape.circle,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                  ),

                                  // Events display section (below calendar)
                                  if (_selectedDay != null && _getEventsForDay(_selectedDay!).isNotEmpty)
                                    Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.2),
                                            spreadRadius: 2,
                                            blurRadius: 8,
                                            offset: Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.all(20),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            // Date Header (Title of the day in white and blue background)
                                            Container(
                                              width: double.infinity,
                                              padding: EdgeInsets.all(16),
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [Colors.lightBlue[400]!, Colors.lightBlue[600]!],
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                ),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Row(
                                                children: [
                                                  Icon(Icons.calendar_today, color: Colors.white, size: 24),
                                                  SizedBox(width: 12),
                                                  Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        "${_selectedDay!.day} ${_getMonthName(_selectedDay!.month)} ${_selectedDay!.year}",
                                                        style: TextStyle(
                                                          fontSize: 20,
                                                          fontWeight: FontWeight.bold,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                      Text(
                                                        "${_getEventsForDay(_selectedDay!).length} event${_getEventsForDay(_selectedDay!).length != 1 ? 's' : ''} scheduled",
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          color: Colors.white.withOpacity(0.9),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),

                                            SizedBox(height: 16),

                                            // Events List of the day (Below the title)
                                            ..._getEventsForDay(_selectedDay!).asMap().entries.map((entry) {
                                              int index = entry.key;
                                              Event event = entry.value;
                                              return Container(
                                                margin: EdgeInsets.only(bottom: 12),
                                                decoration: BoxDecoration(
                                                  color: Colors.lightBlue[50],
                                                  borderRadius: BorderRadius.circular(12),
                                                  border: Border.all(color: Colors.lightBlue.withOpacity(0.2)),
                                                ),
                                                child: ListTile(
                                                  contentPadding: EdgeInsets.all(16),
                                                  leading: Container(
                                                    width: 50,
                                                    height: 50,
                                                    decoration: BoxDecoration(
                                                      gradient: LinearGradient(
                                                        colors: [Colors.lightBlue[300]!, Colors.lightBlue[500]!],
                                                        begin: Alignment.topLeft,
                                                        end: Alignment.bottomRight,
                                                      ),
                                                      borderRadius: BorderRadius.circular(25),
                                                    ),
                                                    child: Center(
                                                      child: Text(
                                                        "${index + 1}",
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 18,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  title: Text(
                                                    event.event_title,
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 16,
                                                      color: Colors.lightBlue[800],
                                                    ),
                                                  ),
                                                  subtitle: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      SizedBox(height: 8),
                                                      Row(
                                                        children: [
                                                          Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                                                          SizedBox(width: 4),
                                                          Text(
                                                            event.event_time.format(context),
                                                            style: TextStyle(
                                                              color: Colors.grey[700],
                                                              fontWeight: FontWeight.w500,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(height: 4),
                                                      Row(
                                                        children: [
                                                          Icon(Icons.people, size: 16, color: Colors.grey[600]),
                                                          SizedBox(width: 4),
                                                          Text(
                                                            "${event.event_participants.length} participant${event.event_participants.length != 1 ? 's' : ''}",
                                                            style: TextStyle(
                                                              color: Colors.grey[700],
                                                              fontWeight: FontWeight.w500,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                  trailing: Container(
                                                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                                    decoration: BoxDecoration(
                                                      color: Colors.lightBlue,
                                                      borderRadius: BorderRadius.circular(20),
                                                    ),
                                                    child: Text(
                                                      "Details",
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                  onTap: () {
                                                    //Alert message displayed when clicking an event already created
                                                    showDialog(
                                                      context: context,
                                                      builder: (BuildContext context) {
                                                        return AlertDialog(
                                                          title: Text("Event Details"),
                                                          content: StatefulBuilder(
                                                            builder: (BuildContext context, StateSetter setDialogState) {
                                                              return SingleChildScrollView(
                                                                child: Column(
                                                                  mainAxisSize: MainAxisSize.min,
                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                  children: [
                                                                    Text("Event name: ${event.event_title}"),
                                                                    Text(
                                                                      "Date: ${event.event_date.toString().split(' ')[0]}",
                                                                    ),
                                                                    Text("Time: ${event.event_time.format(context)}"),
                                                                    Text(
                                                                      "Number of participants: ${event.event_participants.length}",
                                                                    ),
                                                                    SizedBox(height: 10),
                                                                    Text(
                                                                      "Participants:",
                                                                      style: TextStyle(fontWeight: FontWeight.bold),
                                                                    ),
                                                                    if (event.event_participants.isEmpty)
                                                                      Text(
                                                                        "No participants added",
                                                                        style: TextStyle(fontStyle: FontStyle.italic),
                                                                      )
                                                                    else
                                                                      ...event.event_participants.map(
                                                                        (participant) => Padding(
                                                                          padding: EdgeInsets.only(left: 16),
                                                                          child: Row(
                                                                            children: [
                                                                              Container(
                                                                                width: 8,
                                                                                height: 8,
                                                                                decoration: BoxDecoration(
                                                                                  color: _getStatusColor(
                                                                                    participant.$2,
                                                                                  ),
                                                                                  shape: BoxShape.circle,
                                                                                ),
                                                                              ),
                                                                              SizedBox(width: 8),
                                                                              Text("${participant.$1.name}"),
                                                                              SizedBox(width: 8),
                                                                              DropdownButton<String>(
                                                                                value: participant.$2,
                                                                                hint: Text('Define a status'),
                                                                                items: precense.map((String s) {
                                                                                  return DropdownMenuItem<String>(
                                                                                    value: s,
                                                                                    child: Text(s),
                                                                                  );
                                                                                }).toList(),
                                                                                onChanged: (String? newState) {
                                                                                  if (newState != null) {
                                                                                    setDialogState(() {
                                                                                      _updateParticipantStatus(
                                                                                        event,
                                                                                        participant.$1,
                                                                                        newState,
                                                                                        participant.$2,
                                                                                      );
                                                                                    });
                                                                                  }
                                                                                },
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                  ],
                                                                ),
                                                              );
                                                            },
                                                          ),
                                                          actions: [
                                                            TextButton(
                                                              onPressed: () => Navigator.of(context).pop(),
                                                              child: Text("Close"),
                                                            ),
                                                          ],
                                                        );
                                                      },
                                                    );
                                                  },
                                                ),
                                              );
                                            }).toList(),
                                          ],
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),

                            SizedBox(width: 10),
                            // Form section (takes 30% of width)
                            Expanded(
                              flex: 30,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.3),
                                      spreadRadius: 2,
                                      blurRadius: 8,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(20),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Event Creation",
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.lightBlue,
                                        ),
                                      ),
                                      SizedBox(height: 20),

                                      Container(
                                        padding: EdgeInsets.all(20),
                                        decoration: BoxDecoration(
                                          color: Colors.lightBlue.withOpacity(0.05),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: Colors.lightBlue.withOpacity(0.2)),
                                        ),
                                        child: MyForm(
                                          onEventCreated: () {
                                            setState(() {
                                              // This will trigger a rebuild of the calendar
                                            });
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      : Column(
                          // Stack vertically on smaller screens
                          children: [
                            // Calendar section (full width on small screens)
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.2),
                                    spreadRadius: 3,
                                    blurRadius: 10,
                                    offset: Offset(0, 5),
                                  ),
                                ],
                              ),
                              margin: EdgeInsets.only(bottom: 20),
                              padding: EdgeInsets.all(16),
                              child: TableCalendar<Event>(
                                firstDay: DateTime.utc(2020, 1, 1),
                                lastDay: DateTime.utc(2030, 12, 31),
                                focusedDay: _focusedDay,
                                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                                onDaySelected: (selectedDay, focusedDay) {
                                  setState(() {
                                    _selectedDay = selectedDay;
                                    _focusedDay = focusedDay;
                                  });
                                },
                                headerStyle: HeaderStyle(
                                  formatButtonVisible: false,
                                  titleCentered: true,
                                  titleTextStyle: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.lightBlue,
                                  ),
                                  leftChevronIcon: Icon(Icons.chevron_left, color: Colors.lightBlue),
                                  rightChevronIcon: Icon(Icons.chevron_right, color: Colors.lightBlue),
                                ),
                                daysOfWeekStyle: DaysOfWeekStyle(
                                  weekdayStyle: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w600),
                                  weekendStyle: TextStyle(color: Colors.lightBlue[300], fontWeight: FontWeight.w600),
                                ),
                                calendarStyle: CalendarStyle(
                                  outsideDaysVisible: false,
                                  todayDecoration: BoxDecoration(color: Colors.black, shape: BoxShape.circle),
                                  selectedDecoration: BoxDecoration(color: Colors.lightBlue, shape: BoxShape.circle),
                                  weekendTextStyle: TextStyle(color: Colors.lightBlue[400]),
                                  holidayTextStyle: TextStyle(color: Colors.red[400]),
                                ),
                                calendarBuilders: CalendarBuilders(
                                  defaultBuilder: (context, day, focusedDay) {
                                    final dayEvents = _getEventsForDay(day);
                                    if (dayEvents.isNotEmpty) {
                                      final attendanceColor = _getDayAttendanceColor(day);
                                      return Container(
                                        margin: const EdgeInsets.all(4.0),
                                        decoration: BoxDecoration(
                                          color: attendanceColor,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: attendanceColor.withOpacity(0.4),
                                              spreadRadius: 1,
                                              blurRadius: 3,
                                              offset: Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        alignment: Alignment.center,
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              '${day.day}',
                                              style: TextStyle(
                                                color: attendanceColor == Colors.grey[300]
                                                    ? Colors.black87
                                                    : Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                            ),
                                            Container(
                                              margin: EdgeInsets.only(top: 2),
                                              width: 6,
                                              height: 6,
                                              decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                            ),
                                          ],
                                        ),
                                      );
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ),

                            // Events display section (below calendar on small screens)
                            if (_selectedDay != null && _getEventsForDay(_selectedDay!).isNotEmpty)
                              Container(
                                width: double.infinity,
                                margin: EdgeInsets.only(bottom: 20),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.2),
                                      spreadRadius: 2,
                                      blurRadius: 8,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(20),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Date Header
                                      Container(
                                        width: double.infinity,
                                        padding: EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [Colors.lightBlue[400]!, Colors.lightBlue[600]!],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(Icons.calendar_today, color: Colors.white, size: 24),
                                            SizedBox(width: 12),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "${_selectedDay!.day} ${_getMonthName(_selectedDay!.month)} ${_selectedDay!.year}",
                                                  style: TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                Text(
                                                  "${_getEventsForDay(_selectedDay!).length} event${_getEventsForDay(_selectedDay!).length != 1 ? 's' : ''} scheduled",
                                                  style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.9)),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),

                                      SizedBox(height: 16),

                                      // Events List
                                      ..._getEventsForDay(_selectedDay!).asMap().entries.map((entry) {
                                        int index = entry.key;
                                        Event event = entry.value;
                                        return Container(
                                          margin: EdgeInsets.only(bottom: 12),
                                          decoration: BoxDecoration(
                                            color: Colors.lightBlue[50],
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(color: Colors.lightBlue.withOpacity(0.2)),
                                          ),
                                          child: ListTile(
                                            contentPadding: EdgeInsets.all(16),
                                            leading: Container(
                                              width: 50,
                                              height: 50,
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [Colors.lightBlue[300]!, Colors.lightBlue[500]!],
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                ),
                                                borderRadius: BorderRadius.circular(25),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  "${index + 1}",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            title: Text(
                                              event.event_title,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                                color: Colors.lightBlue[800],
                                              ),
                                            ),
                                            subtitle: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                SizedBox(height: 8),
                                                Row(
                                                  children: [
                                                    Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                                                    SizedBox(width: 4),
                                                    Text(
                                                      event.event_time.format(context),
                                                      style: TextStyle(
                                                        color: Colors.grey[700],
                                                        fontWeight: FontWeight.w500,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(height: 4),
                                                Row(
                                                  children: [
                                                    Icon(Icons.people, size: 16, color: Colors.grey[600]),
                                                    SizedBox(width: 4),
                                                    Text(
                                                      "${event.event_participants.length} participant${event.event_participants.length != 1 ? 's' : ''}",
                                                      style: TextStyle(
                                                        color: Colors.grey[700],
                                                        fontWeight: FontWeight.w500,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            trailing: Container(
                                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                              decoration: BoxDecoration(
                                                color: Colors.lightBlue,
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                              child: Text(
                                                "Details",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            onTap: () {
                                              showDialog(
                                                context: context,
                                                builder: (BuildContext context) {
                                                  return AlertDialog(
                                                    title: Text("Event Details"),
                                                    content: StatefulBuilder(
                                                      builder: (BuildContext context, StateSetter setDialogState) {
                                                        return SingleChildScrollView(
                                                          child: Column(
                                                            mainAxisSize: MainAxisSize.min,
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              Text("Event name: ${event.event_title}"),
                                                              Text(
                                                                "Date: ${event.event_date.toString().split(' ')[0]}",
                                                              ),
                                                              Text("Time: ${event.event_time.format(context)}"),
                                                              Text(
                                                                "Number of participants: ${event.event_participants.length}",
                                                              ),
                                                              SizedBox(height: 10),
                                                              Text(
                                                                "Participants:",
                                                                style: TextStyle(fontWeight: FontWeight.bold),
                                                              ),
                                                              if (event.event_participants.isEmpty)
                                                                Text(
                                                                  "No participants added",
                                                                  style: TextStyle(fontStyle: FontStyle.italic),
                                                                )
                                                              else
                                                                ...event.event_participants.map(
                                                                  (participant) => Padding(
                                                                    padding: EdgeInsets.only(left: 16),
                                                                    child: Row(
                                                                      children: [
                                                                        Container(
                                                                          width: 8,
                                                                          height: 8,
                                                                          decoration: BoxDecoration(
                                                                            color: _getStatusColor(participant.$2),
                                                                            shape: BoxShape.circle,
                                                                          ),
                                                                        ),
                                                                        SizedBox(width: 8),
                                                                        Text("${participant.$1.name}"),
                                                                        SizedBox(width: 8),
                                                                        DropdownButton<String>(
                                                                          value: participant.$2,
                                                                          hint: Text('Define a status'),
                                                                          items: precense.map((String s) {
                                                                            return DropdownMenuItem<String>(
                                                                              value: s,
                                                                              child: Text(s),
                                                                            );
                                                                          }).toList(),
                                                                          onChanged: (String? newState) {
                                                                            if (newState != null) {
                                                                              setDialogState(() {
                                                                                _updateParticipantStatus(
                                                                                  event,
                                                                                  participant.$1,
                                                                                  newState,
                                                                                  participant.$2,
                                                                                );
                                                                              });
                                                                            }
                                                                          },
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                            ],
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () => Navigator.of(context).pop(),
                                                        child: Text("Close"),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
                                            },
                                          ),
                                        );
                                      }).toList(),
                                    ],
                                  ),
                                ),
                              ),

                            // Form section (full width on small screens)
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.3),
                                    spreadRadius: 2,
                                    blurRadius: 8,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Event Creation",
                                      style: TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.lightBlue,
                                      ),
                                    ),
                                    SizedBox(height: 20),

                                    Container(
                                      width: double.infinity,
                                      padding: EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        color: Colors.lightBlue.withOpacity(0.05),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: Colors.lightBlue.withOpacity(0.2)),
                                      ),
                                      child: MyForm(
                                        onEventCreated: () {
                                          setState(() {
                                            // Triggers a rebuild of the calendar
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
