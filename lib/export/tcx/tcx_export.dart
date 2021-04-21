import 'dart:convert';
import 'dart:math';

import '../../persistence/preferences.dart';
import '../../utils/constants.dart';
import '../../utils/statistics_accumulator.dart';
import '../activity_export.dart';
import '../export_model.dart';
import '../export_record.dart';

class TCXExport extends ActivityExport {
  static String nonCompressedFileExtension = 'tcx';
  static String compressedFileExtension = nonCompressedFileExtension + '.gz';
  static String nonCompressedMimeType = 'text/xml';
  static String compressedMimeType = 'application/x-gzip';

  StringBuffer _sb;

  // StringBuffer get sb => _sb;

  TCXExport() : super() {
    _sb = StringBuffer();
  }

  Future<List<int>> getFileCore(ExportModel exportModel) async {
    // The prolog of the TCX file
    _sb.write("""<?xml version="1.0" encoding="UTF-8"?>
<TrainingCenterDatabase
    xsi:schemaLocation="http://www.garmin.com/xmlschemas/TrainingCenterDatabase/v2 http://www.garmin.com/xmlschemas/TrainingCenterDatabasev2.xsd"
    xmlns:ns5="http://www.garmin.com/xmlschemas/ActivityGoals/v1"
    xmlns:ns3="http://www.garmin.com/xmlschemas/ActivityExtension/v2"
    xmlns:ns2="http://www.garmin.com/xmlschemas/UserProfile/v2"
    xmlns="http://www.garmin.com/xmlschemas/TrainingCenterDatabase/v2"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:ns4="http://www.garmin.com/xmlschemas/ProfileExtension/v1">""");

    addActivity(exportModel);
    addAuthor(exportModel);

    _sb.write("</TrainingCenterDatabase>\n");

    return utf8.encode(_sb.toString());
  }

  void addActivity(ExportModel exportModel) {
    // Add Activity
    //-------------
    _sb.write("""  <Activities>
    <Activity Sport="${exportModel.activityType}">\n""");

    // Add ID
    addElement('Id', timeStampString(exportModel.dateActivity));
    addLap(exportModel);
    addCreator(exportModel);

    _sb.write("    </Activity>\n");
    _sb.write("  </Activities>\n");
  }

  void addLap(ExportModel exportModel) {
    // Add lap
    //---------
    _sb.write('        <Lap StartTime="${timeStampString(exportModel.dateActivity)}">\n');

    // Assuming that points are ordered by time stamp ascending
    ExportRecord lastRecord = exportModel.points.last;
    if (lastRecord != null) {
      if ((exportModel.totalTime == null || exportModel.totalTime == 0) &&
          lastRecord.date != null) {
        exportModel.totalTime = lastRecord.date.millisecondsSinceEpoch / 1000;
      }
      if ((exportModel.totalDistance == null || exportModel.totalDistance == 0) &&
          lastRecord.distance > 0) {
        exportModel.totalDistance = lastRecord.distance;
      }
    }

    addElement('TotalTimeSeconds', exportModel.totalTime.toString());
    // Add Total distance in meters
    addElement('DistanceMeters', exportModel.totalDistance.toStringAsFixed(2));

    final calculateMaxSpeed = exportModel.maxSpeed == null || exportModel.maxSpeed == 0;
    final calculateAvgHeartRate =
        exportModel.averageHeartRate == null || exportModel.averageHeartRate == 0;
    final calculateMaxHeartRate =
        exportModel.maximumHeartRate == null || exportModel.maximumHeartRate == 0;
    final calculateAvgCadence =
        exportModel.averageCadence == null || exportModel.averageCadence == 0;
    var accu = StatisticsAccumulator(
      si: true,
      sport: ActivityType.Ride,
      calculateMaxSpeed: calculateMaxSpeed,
      calculateAvgHeartRate: calculateAvgHeartRate,
      calculateMaxHeartRate: calculateMaxHeartRate,
      calculateAvgCadence: calculateAvgCadence,
    );
    if (calculateMaxSpeed ||
        calculateAvgHeartRate ||
        calculateMaxHeartRate ||
        calculateAvgCadence) {
      exportModel.points.forEach((trackPoint) {
        accu.processExportRecord(trackPoint);
      });
    }
    if (calculateMaxSpeed) {
      exportModel.maxSpeed = accu.maxSpeed;
    }
    if (calculateAvgHeartRate && accu.heartRateCount > 0) {
      exportModel.averageHeartRate = accu.avgHeartRate;
    }
    if (calculateMaxHeartRate && accu.maxHeartRate > 0) {
      exportModel.maximumHeartRate = accu.maxHeartRate;
    }
    if (calculateAvgCadence && accu.cadenceCount > 0) {
      exportModel.averageCadence = accu.avgCadence;
    }

    // Add Maximum speed in meter/second
    addElement('MaximumSpeed', exportModel.maxSpeed.toStringAsFixed(2));

    if ((exportModel.averageHeartRate ?? 0) > 0) {
      addElement('AverageHeartRateBpm', exportModel.averageHeartRate.toStringAsFixed(2));
    }
    if ((exportModel.maximumHeartRate ?? 0) > 0) {
      addElement('MaximumHeartRateBpm', exportModel.maximumHeartRate.toString());
    }
    if ((exportModel.averageCadence ?? 0) > 0) {
      final cadence = min(max(exportModel.averageCadence, 0), 254).toInt();
      addElement('Cadence', cadence.toStringAsFixed(2));
    }

    // Add calories
    addElement('Calories', exportModel.calories.toString());
    // Add intensity (what is the meaning?)
    addElement('Intensity', 'Active');
    // Add intensity (what is the meaning?)
    addElement('TriggerMethod', 'Manual');

    addTrack(exportModel);

    _sb.write('        </Lap>\n');
  }

  void addTrack(ExportModel exportModel) {
    _sb.write('          <Track>\n');

    // Add track inside the lap
    for (var point in exportModel.points) {
      addTrackPoint(point);
    }

    _sb.write('          </Track>\n');
  }

  /// Generate a string that will include
  /// all the tags corresponding to TCX trackpoint
  ///
  /// Extension handling is missing for the moment
  ///
  void addTrackPoint(ExportRecord point) {
    _sb.write("<Trackpoint>\n");
    addElement('Time', point.timeStampString);
    addPosition(point.latitude.toStringAsFixed(10), point.longitude.toStringAsFixed(10));
    addElement('AltitudeMeters', point.altitude.toString());
    addElement('DistanceMeters', point.distance.toStringAsFixed(2));
    if (point.cadence != null) {
      final cadence = min(max(point.cadence, 0), 254).toInt();
      addElement('Cadence', cadence.toString());
    }

    addExtensions('Speed', point.speed.toStringAsFixed(2), 'Watts', point.power);

    if (point.heartRate != null) {
      if (heartRateUpperLimit > 0 &&
          point.heartRate > heartRateUpperLimit &&
          heartRateLimitingMethod != HEART_RATE_LIMITING_NO_LIMIT) {
        bool persist = false;
        if (heartRateLimitingMethod == HEART_RATE_LIMITING_CAP_AT_LIMIT) {
          point.heartRate = heartRateUpperLimit;
          persist = true;
        } else {
          point.heartRate = 0;
          persist = heartRateLimitingMethod == HEART_RATE_LIMITING_WRITE_ZERO;
        }

        if (persist) {
          addHeartRate(point.heartRate);
        }
      } else if (point.heartRate > 0 ||
          heartRateGapWorkaround == DATA_GAP_WORKAROUND_NO_WORKAROUND ||
          heartRateLimitingMethod == HEART_RATE_LIMITING_WRITE_ZERO) {
        addHeartRate(point.heartRate);
      }
    }

    _sb.write("</Trackpoint>\n");
  }

  void addCreator(ExportModel exportModel) {
    _sb.write("""    <Creator xsi:type="Device_t">
      <Name>${exportModel.deviceName}</Name>
      <UnitId>${exportModel.unitID}</UnitId>
      <ProductID>${exportModel.productID}</ProductID>
      <Version>
        <VersionMajor>${exportModel.versionMajor}</VersionMajor>
        <VersionMinor>${exportModel.versionMinor}</VersionMinor>
        <BuildMajor>${exportModel.buildMajor}</BuildMajor>
        <BuildMinor>${exportModel.buildMinor}</BuildMinor>
      </Version>
    </Creator>\n""");
  }

  void addAuthor(ExportModel exportModel) {
    _sb.write("""  <Author xsi:type="Application_t">
    <Name>${exportModel.author}</Name>
    <Build>
      <Version>
        <VersionMajor>${exportModel.versionMajor}</VersionMajor>
        <VersionMinor>${exportModel.versionMinor}</VersionMinor>
        <BuildMajor>${exportModel.buildMajor}</BuildMajor>
        <BuildMinor>${exportModel.buildMinor}</BuildMinor>
      </Version>
    </Build>
    <LangID>${exportModel.langID}</LangID>
    <PartNumber>${exportModel.partNumber}</PartNumber>
  </Author>\n""");
  }

  /// Add extension of speed and watts
  ///
  ///  <Extensions>
  ///              <ns3:TPX>
  ///                <ns3:Speed>1.996999979019165</ns3:Speed>
  ///              </ns3:TPX>
  ///            </Extensions>
  ///
  /// Does not handle multiple values like
  /// Speed AND Watts in the same extension
  ///
  void addExtensions(String tag1, String value1, String tag2, double value2) {
    double _value = value2 ?? 0.0;
    _sb.write("""    <Extensions>
      <ns3:TPX>
        <ns3:$tag1>$value1</ns3:$tag1>
        <ns3:$tag2>${_value.toString()}</ns3:$tag2>
      </ns3:TPX>
    </Extensions>\n""");
  }

  /// Add heartRate in TCX file to look like
  ///
  ///       <HeartRateBpm>
  ///         <Value>61</Value>
  ///       </HeartRateBpm>
  ///
  void addHeartRate(int heartRate) {
    int _heartRate = heartRate ?? 0;
    _sb.write("""                 <HeartRateBpm xsi:type="HeartRateInBeatsPerMinute_t">
                <Value>${_heartRate.toString()}</Value>
              </HeartRateBpm>\n""");
  }

  /// create a position something like
  /// <Position>
  ///   <LatitudeDegrees>43.14029800705612</LatitudeDegrees>
  ///   <LongitudeDegrees>5.771340150386095</LongitudeDegrees>
  /// </Position>
  void addPosition(String latitude, String longitude) {
    _sb.write("""<Position>
     <LatitudeDegrees>$latitude</LatitudeDegrees>
     <LongitudeDegrees>$longitude</LongitudeDegrees>
  </Position>\n""");
  }

  /// create XML element
  /// from content string
  void addElement(String tag, String content) {
    _sb.write('<$tag>$content</$tag>\n');
  }

  /// create XML attribute
  /// from content string
  void addAttribute(String tag, String attribute, String value, String content) {
    _sb.write('<$tag $attribute="$value">\n$content</$tag>\n');
  }

  /// Create timestamp for <Time> element in TCX file
  ///
  /// To get 2019-03-03T11:43:46.000Z
  /// utc time
  /// Need to add T in the middle
  String timeStampString(DateTime dateTime) {
    return dateTime.toUtc().toString().replaceFirst(' ', 'T');
  }

  int timeStampInteger(DateTime dateTime) {
    return 0; // Not used for TCX
  }
}
