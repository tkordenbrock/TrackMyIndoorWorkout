import 'package:floor/floor.dart';
import 'package:meta/meta.dart';
import '../../persistence/preferences.dart';
import '../../tcx/activity_type.dart';
import 'activity.dart';

const String RECORDS_TABLE_NAME = 'records';

@Entity(tableName: RECORDS_TABLE_NAME, foreignKeys: [
  ForeignKey(
    childColumns: ['activity_id'],
    parentColumns: ['id'],
    entity: Activity,
  )
], indices: [
  Index(value: ['time_stamp'])
])
class Record {
  @PrimaryKey(autoGenerate: true)
  int id;
  @ColumnInfo(name: 'activity_id')
  final int activityId;
  @ColumnInfo(name: 'time_stamp')
  final int timeStamp; // ms since epoch
  final double distance; // m
  final int elapsed; // s
  final int calories; // kCal
  final int power; // W
  double speed; // km/h
  final int cadence;
  @ColumnInfo(name: 'heart_rate')
  final int heartRate;

  @ignore
  DateTime dt;
  @ignore
  int elapsedMillis;
  @ignore
  double pace;
  @ignore
  double strokeCount;
  @ignore
  String sport;

  Record({
    this.id,
    this.activityId,
    this.timeStamp,
    this.distance,
    this.elapsed,
    this.calories,
    this.power,
    this.speed,
    this.cadence,
    this.heartRate,
    this.elapsedMillis,
    this.pace,
    this.strokeCount,
    this.sport,
  }) {
    if (sport != null && speed == null && pace != null) {
      if (sport == ActivityType.Kayaking ||
          sport == ActivityType.Canoeing ||
          sport == ActivityType.Rowing) {
        if (pace.abs() < 10e-4) {
          speed = 0.0;
        } else {
          speed = 30.0 / (pace / 60.0);
        }
      } else {
        // sport == ActivityType.Run
        if (pace.abs() < 10e-4) {
          speed = 0.0;
        } else {
          speed = 60.0 / pace;
        }
      }
    }
  }

  Record hydrate() {
    dt = DateTime.fromMillisecondsSinceEpoch(timeStamp);
    return this;
  }

  double speedByUnit(bool si, String sport) {
    if (sport == ActivityType.Ride) {
      if (si) return speed;
      return speed * KM2MI;
    } else if (sport == ActivityType.Run) {
      if (speed.abs() < 10e-4) return 0.0;
      final pace = 60.0 / speed;
      if (si) return pace;
      return pace / KM2MI; // mph is lower than kmh but pace is reciprocal
    } else if (sport == ActivityType.Kayaking ||
        sport == ActivityType.Canoeing ||
        sport == ActivityType.Rowing) {
      if (speed.abs() < 10e-4) return 0.0;
      return 30.0 / speed;
    }
    return speed;
  }

  static String paceString(double pace) {
    final minutes = pace.truncate();
    final seconds = ((pace - minutes) * 60.0).truncate();
    return "$minutes:" + seconds.toString().padLeft(2, "0");
  }

  String speedStringByUnit(bool si, String sport) {
    final spd = speedByUnit(si, sport);
    if (sport == ActivityType.Ride) {
      return spd.toStringAsFixed(2);
    } else if (sport == ActivityType.Run ||
        sport == ActivityType.Kayaking ||
        sport == ActivityType.Canoeing ||
        sport == ActivityType.Rowing) {
      if (speed.abs() < 10e-4) return "0:00";
      var pace = 60.0 / speed;
      if (sport == ActivityType.Kayaking ||
          sport == ActivityType.Canoeing ||
          sport == ActivityType.Rowing) {
        pace /= 2.0;
      } else if (!si) {
        pace /= KM2MI;
      }
      return paceString(pace);
    }
    return spd.toStringAsFixed(2);
  }

  double distanceByUnit(bool si) {
    if (si) return distance;
    return distance * M2MILE;
  }

  String distanceStringByUnit(bool si) {
    final dist = distanceByUnit(si);
    return dist.toStringAsFixed(si ? 0 : 2);
  }
}

class RecordWithSport extends Record {
  RecordWithSport({
    id,
    activityId,
    timeStamp,
    distance,
    elapsed,
    calories,
    power,
    speed,
    cadence,
    heartRate,
    elapsedMillis,
    pace,
    strokeCount,
    @required sport,
  })  : assert(sport != null),
        super(
          id: id,
          activityId: activityId,
          timeStamp: timeStamp,
          distance: distance,
          elapsed: elapsed,
          calories: calories,
          power: power,
          speed: speed,
          cadence: cadence,
          heartRate: heartRate,
          elapsedMillis: elapsedMillis,
          pace: pace,
          strokeCount: strokeCount,
          sport: sport,
        );
}
