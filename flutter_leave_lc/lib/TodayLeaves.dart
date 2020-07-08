import 'package:flutter/material.dart';
import 'package:leancloud_storage/leancloud.dart';
import 'Common/Global.dart';
import 'package:date_format/date_format.dart';

class TodayLeavesPage extends StatefulWidget {
  @override
  _TodayLeavesPageState createState() => new _TodayLeavesPageState();
}

class _TodayLeavesPageState extends State<TodayLeavesPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
//        padding: EdgeInsets.all(2.0),
        child: FutureBuilder<List<LCObject>>(
          future: retrieveData(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            // 请求已结束
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasError) {
                return Text("Error: ${snapshot.error}");
              } else {
                return ListView.separated(
                  //添加分割线
                  separatorBuilder: (BuildContext context, int index) {
                    return new Divider(
                      height: 0.8,
                      color: Colors.grey,
                    );
                  },
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: snapshot.data.length,
                  itemBuilder: (context, index) {
                    var data = snapshot.data[index];
                    int type = data['type'];
                    String name;
                    String username = data['username'];
                    String realName = data['realName'];
                    if (realName == null || realName == '') {
                      name = username;
                    } else {
                      name = realName;
                    }
                    var duration = data['duration'];
                    String note;
                    if (data['note'] == null || data['note'] == '') {
                      note = '（因为某些羞羞的原因）';
                    } else {
                      note = data['note'];
                    }
                    DateTime startDate = data['startDate'];
                    String startDateString =
                        formatDate(startDate, [mm, "-", dd, " "]);
                    DateTime endDate = data['endDate'];
                    String endDateString =
                        formatDate(endDate, [mm, "-", dd, " "]);
                    String startTime = data['startTime'];
                    String endTime = data['endTime'];

                    String leaveMessageString =
                        '$startDateString$startTime - $endDateString$endTime';
                    return Container(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        children: <Widget>[
                          new Expanded(
                            flex: 2,
                            child: new Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                new Container(
                                  padding: const EdgeInsets.only(
                                      bottom: 8.0, right: 8, left: 10),
                                  child: new Text(
                                    '$name ${getVacationTypeString(type)}',
                                    style: new TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                new Container(
                                  padding: const EdgeInsets.only(
                                      bottom: 8.0, right: 8, left: 10),
                                  child: new Text(
                                    note,
                                    style: new TextStyle(
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                ),
                                new Container(
                                  padding:
                                      const EdgeInsets.only(right: 8, left: 10),
                                  child: new Text(
                                    leaveMessageString,
                                    style: new TextStyle(
                                      color: Colors.black54,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          new Expanded(
                            flex: 1,
                            child: new Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                new Container(
                                  padding: const EdgeInsets.only(
                                      bottom: 8.0, right: 15),
                                  child: new Text(
                                    '${duration.toString()} 天',
                                    style: new TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              }
            } else {
              // 请求未结束，显示loading
              return CircularProgressIndicator();
            }
          },
        ),
      ),
    );
  }

  Future<List<LCObject>> retrieveData() async {
    LCQuery<LCObject> query = LCQuery('Leave');
    DateTime today = formatDateForYMD(DateTime.now());
    query.whereGreaterThanOrEqualTo('endDate', today);
    query.whereLessThanOrEqualTo('startDate', today);
    query.orderByDescending('createdAt');
    query.limit(100);
    List<LCObject> leaves = await query.find();
    return leaves;
  }
}
