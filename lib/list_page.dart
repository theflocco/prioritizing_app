import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:prioritizing_app/app_builder.dart';
import 'package:prioritizing_app/bottom_bar.dart';
import 'package:prioritizing_app/custom_dialog.dart';
import 'package:prioritizing_app/data_service.dart';
import 'package:prioritizing_app/database_helper.dart';
import 'package:prioritizing_app/model/task.dart';
import 'package:sqflite/sqlite_api.dart';

class ListPage extends StatefulWidget {
  ListPage({Key key, this.task}) : super(key: key);
  final Task task;

  @override
  State<StatefulWidget> createState() {
    return _ListPageState();
  }
}

  class _ListPageState extends State<ListPage> {
  Future<List<Task>> taskListFuture;
  DatabaseHelper db;

  @override
  void initState() {
    super.initState();
    db = DatabaseHelper.instance;
    refreshList();

  }

  refreshList() {
    setState(() {
      taskListFuture = db.getAllTasks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppBuilder(builder: (context) {
      return Scaffold(
        backgroundColor: Color.fromRGBO(58, 66, 86, 1.0),
        appBar: topAppBar(context),
        body: _taskListView(context),
        bottomNavigationBar:BottomBarWidget(context)
      );
    });
  }
  Widget _taskListView(
      BuildContext context) {
    return FutureBuilder<List<Task>>(
      future: taskListFuture,
      builder: (BuildContext context, AsyncSnapshot<List<Task>> snapshot) {
        if (snapshot.hasData) {
          return dataTable(snapshot.data);
        }
        if (null == snapshot.data || snapshot.data.length == 0) {
          return addSomeTasksText();
        }
        return CircularProgressIndicator();
      },
    );
  }




  Widget topAppBar(BuildContext context) {
    return new AppBar(
      elevation: 0.1,
      backgroundColor: Color.fromRGBO(58, 66, 86, 1.0),
      title: Text('Sira',style: TextStyle(fontSize: 36.0, fontWeight: FontWeight.w400),),
      actions: <Widget>[
        IconButton(
            icon: Icon(Icons.add),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CustomDialog()),
              );
              refreshList();
              //AppBuilder.of(context).rebuild();
            })
      ],
    );
  }

  addSomeTasksText() {
    return Center(
      child: Container(child: new Text(
        'Add Some Tasks!',
        style: new TextStyle(
          color: Colors.white,
          fontSize: 40.0,
          fontWeight: FontWeight.w200)
      ),
      ),
    );
  }
  dataTable(List<Task> taskList) {
          return ListView.builder(
            itemCount: taskList.length,
            itemBuilder: (context, index) {
              return Dismissible(
                  child: Container(
                    decoration: new BoxDecoration(boxShadow: [
                      new BoxShadow(
                        offset: new Offset(0.0, 10.0),
                        color: Colors.black38,
                        blurRadius: 10.0,
                      )
                    ]),
                    child: Card(
                        color: taskList[index].returnPriorityColor(),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
                        child: ClipPath(
                          child: Container(
                            height: 90,
                            child: Padding(
                              child: Row(
                                children: <Widget>[
                                  Container(
                                    padding: EdgeInsets.all(20),
                                    child: Text(
                                      taskList[index].getTaskName,
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 26.0,
                                          fontWeight: FontWeight.w400),
                                    ),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(10.0),
                            ),
                          ),
                        )),
                  ),
                  key: new Key(taskList[index].id.toString()),
                  onDismissed: (direction) {
                    setState(() {
                      db.delete(taskList[index].id);
                      taskList.removeAt(index);
                    });
                    //refreshList();
                  });
            },
          );
  }





}
