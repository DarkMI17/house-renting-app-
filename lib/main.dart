import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  final TextEditingController emailControll = TextEditingController();
  final TextEditingController passwordControll = TextEditingController();
  bool visible = true ;
  final _formKey = GlobalKey<FormState>();

  void validateForm(){
    _formKey.currentState!.validate();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home:Scaffold(
      appBar: AppBar(title: Text("Login"),
      backgroundColor: Colors.teal,),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Form(key: _formKey,
            child: Column(
              children: [
        
                Text("Login",
                style: TextStyle(fontSize: 35 , color: Colors.teal , fontWeight: FontWeight.bold)  ),
        
                SizedBox(height: 20,),
        
                TextFormField( controller: emailControll
                   ,decoration: InputDecoration(labelText: "Email" ,
                 hintText: "enter email" ,
                  border: OutlineInputBorder(),
                  prefix: Container(margin: EdgeInsets.only(right: 10),
                  child: Icon(Icons.email))),
                  validator: (value) {
                    if(emailControll.text.isEmpty){
                      return "this field is empty" ;
                    }
                    // if(emailControll.text.contains('@'))
                    return null ;
                  },
                  ),
        
                  SizedBox(height: 40,),
        
                  TextFormField( controller: passwordControll
                   ,decoration: InputDecoration(labelText: "password" ,
                 hintText: "enter password" ,
                  border: OutlineInputBorder(),
                  prefix: Container(margin: EdgeInsets.only(right: 10)
                    ,child: Icon(Icons.password,)),
                  suffix: IconButton(onPressed: () {
                    setState(() {
                      visible = !visible ;
                    });
                  },
                   icon: Icon(Icons.remove_red_eye))),
                  obscureText: visible,
                  
                  validator: (value) {
                    if(passwordControll.text.isEmpty){
                      return "the password field isa empty";
                    }
                    if(passwordControll.text.length < 3){
                      return "the password must be at least three charactrs long";
                    }
                    return null ;
                  },
                  ),
                  SizedBox(height: 20,),
                  MaterialButton(onPressed:validateForm ,
                  color: Colors.teal,
                  textColor: Colors.white,
                  child: Text("Submit") )
              ],
            ))
          ],
        ),
      ),
    ) ,
    );
    
    
     
  }
}