using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using Microsoft.AspNet.SignalR;

using Microsoft.AspNet.SignalR.Hubs;
using System.Diagnostics;

using Models;
using Classes;
using System.Data;
using System.Security.Policy;
using System.Configuration;


namespace Khupho
{
    [HubName("chatHub")]
    public class ChatHub : Hub
    {
        // ChatAppEntities db = new ChatAppEntities();
        string serverpath = ConfigurationManager.AppSettings["ServerPath"].ToString();
        static bool isFirstRequest = true;

        public void say(string message)
        {
            Clients.All.hello();
            Trace.WriteLine(message);
        }
        static readonly HashSet<string> Rooms = new HashSet<string>();
        static List<user> loggedInUsers = new List<user>();
        //static List<Room> roomsWiseUser = new List<Room>();
        public string Login(string name)
        {
            var user = new user { name = name, ConnectionId = Context.ConnectionId, age = 20, avator = "", id = 1, sex = "Male", memberType = "Registered", fontColor = "red", status = Status.Online.ToString() };
            Clients.Caller.rooms(Rooms.ToArray());
            Clients.Caller.setInitial(Context.ConnectionId, name);
            var oSerializer = new System.Web.Script.Serialization.JavaScriptSerializer();
            string sJSON = oSerializer.Serialize(loggedInUsers);
            loggedInUsers.Add(user);
            Clients.Caller.getOnlineUsers(sJSON);
            Clients.Others.newOnlineUser(user);
            return name;
        }
        public void SendPrivateMessage(string toUserId, string message)
        {

            ChatDataLayer dl = new ChatDataLayer();
            string fromUserId = Context.ConnectionId;
            var toUser = loggedInUsers.FirstOrDefault(x => x.userid == toUserId);
            //var fromUser = loggedInUsers.FirstOrDefault(x => x.ConnectionId == fromUserId);
            var fromUser = loggedInUsers.FirstOrDefault(x => x.ConnectionIds.Contains(fromUserId));
            string msgid = dl.GeenrateRandomnumber("");
            if (toUserId != null && toUserId != "" && fromUser != null)
            {
                DateTime dtime = DateTime.Now;
                Clients.Clients(fromUser.ConnectionIds.ToList()).sendPrivateMessage(msgid, toUserId, fromUser.name, message, dtime.ToString("dd MMM,yyyy hh:mm tt"), "receiver");
                // Clients.Caller.sendPrivateMessage(toUserId, fromUser.name, message, dtime.ToString("dd MMM,yyyy hh:mm tt"), "receiver");

                //---------------------Save Message ---------------------------------
                try
                {
                    if (toUser != null)
                    {

                        Clients.Clients(toUser.ConnectionIds.ToList()).sendPrivateMessage(msgid, fromUser.userid, fromUser.name, message, dtime.ToString("dd MMM,yyyy hh:mm tt"), "sender");
                        //Clients.AllExcept(fromUserId).newMessageflash(toUserId);
                        Clients.Others.newMessageflash(toUserId);
                    }
                }
                catch (Exception)
                {
                }

                MessageModel model = new MessageModel();
                model.Msg_id = msgid;
                model.Msg_From_User_Id = fromUser.userid;
                model.Msg_To_User_Id = toUserId;
                model.Is_Read = "0";
                model.Message = message;
                model.Msg_Date = dtime.ToString("yyyy-MM-dd HH:mm:ss");
                model.Msg_Status = "Send";
                model.IsPublic = "0";
                int i = dl.sendMessage(model);
                if (i > 0)
                {
                }
                //======================================================================
            }
        }
        public void SendMsgToAll()
        {
            string fromUserId = Context.ConnectionId;
            Clients.All.getNewMessages();
            Clients.Others.newMessageflash("");
            //Clients.AllExcept(fromUserId).newMessageflash("");
        }
        public void UpdateStatus(string status)
        {
            string userId = Context.ConnectionId;
            loggedInUsers.FirstOrDefault(x => x.ConnectionId == userId).status = status;
            //var fromUser = loggedInUsers.FirstOrDefault(x => x.ConnectionId == fromUserId);                          
            Clients.Others.statusChanged(userId, status);

        }
        public void UserTyping(string userid, string msg)
        {
            var id = Context.ConnectionId;

            var fromUser = loggedInUsers.FirstOrDefault(x => x.ConnectionIds.Contains(id));
            //var fromUser = loggedInUsers.FirstOrDefault(x => x.ConnectionId == id);

            var toUser = loggedInUsers.FirstOrDefault(x => x.userid == userid);
            if (toUser != null)
            {
                Clients.Client(toUser.ConnectionId).isTyping(fromUser.userid, msg);
            }


        }
        public override System.Threading.Tasks.Task OnDisconnected(bool stopCalled)
        {

            var id = Context.ConnectionId;
            var item = loggedInUsers.FirstOrDefault(x => x.ConnectionIds.Contains(id));


            if (item != null)
            {

                lock (item.ConnectionIds)
                {
                    //Clients.Clients(item.ConnectionIds.ToList()).checkLogin();
                    item.ConnectionIds.RemoveWhere(cid => cid.Equals(id));

                    if (!item.ConnectionIds.Any())
                    {
                        Clients.All.onUserDisconnected(item.userid, item.name);
                        loggedInUsers.Remove(item);
                        Clients.Others.newOfflineUser(item.id, item.name, item.userid, item.avator);
                        //user removedUser;
                        //Users.TryRemove(userName, out removedUser);

                        // You might want to only broadcast this info if this 
                        // is the last connection of the user and the user actual is 
                        // now disconnected from all connections.
                        //Clients.Others.userDisconnected(userName);
                    }
                }
            }

            //var item = loggedInUsers.FirstOrDefault(x => x.ConnectionId == Context.ConnectionId);
            //if (item != null)
            //{               
            //    var id = Context.ConnectionId;
            //    Clients.All.onUserDisconnected(item.userid, item.name);
            //    loggedInUsers.Remove(item);                 
            //    Clients.Others.newOfflineUser(item.id, item.name, item.userid, item.avator);                 
            //}


            return base.OnDisconnected(true);
        }

        List<user> fillwithfriends(string uid)
        {
            AccountDataLayer dl = new AccountDataLayer();
            DataTable frnddt = new DataTable();

            DataSet ds = dl.Inline_Process(@"select * from [dbo].[View_Login_Profile] u where u.UserId in (
                                            select [From] FrndId from [dbo].[Friends_tbl] where [Status]='accepted' and ([From]='" + uid + "' or [To]='" + uid + @"')
                                            Union
                                            select [To] FrndId from [dbo].[Friends_tbl] where [Status]='accepted' and ([From]='" + uid + "' or [To]='" + uid + @"')
                                            )
                                            and u.UserId<>'" + uid + "'");
            if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
            {
                frnddt = ds.Tables[0];
            }

            List<user> tusr = new List<user>();
            foreach (DataRow dr in frnddt.Rows)
            {
                user tmpu = new user();
                tmpu.avator = dr["Photo"].ToString() != "" ? serverpath + "Images/Profile/" + dr["Photo"].ToString() : serverpath + "Content/themes/Sites/images/avtar.png"; ;
                tmpu.userid = dr["UserId"].ToString();
                tmpu.name = dr["ScreenName"].ToString() != "" ? dr["ScreenName"].ToString() : dr["Username"].ToString(); dr["UserId"].ToString();

                if (loggedInUsers.Count(x => x.userid == tmpu.userid) > 0)
                {
                    var element = loggedInUsers.FirstOrDefault(c => c.userid == tmpu.userid);
                    if (element != null)
                    {
                        tmpu.IsOnline = "Y";
                        tmpu.ConnectionId = element.ConnectionId;
                    }
                    else
                    {
                        tmpu.IsOnline = "N";
                        tmpu.ConnectionId = "";
                    }

                }
                else
                {
                    tmpu.IsOnline = "N";
                    tmpu.ConnectionId = "";
                }
                tusr.Add(tmpu);
            }
            return tusr;
        }

        public void Connect(string userName, string uid)
        {
            var id = Context.ConnectionId;
            string _username = "", dp = "";
            AccountDataLayer dl = new AccountDataLayer();
            DataSet ds = dl.Inline_Process("select Photo,(firstName+' '+LastName) as Username,ScreenName from [dbo].[View_Login_Profile] where UserId='" + uid + @"'");
            if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
            {
                _username = ds.Tables[0].Rows[0]["ScreenName"].ToString() != "" ? ds.Tables[0].Rows[0]["ScreenName"].ToString() : ds.Tables[0].Rows[0]["Username"].ToString();
                dp = ds.Tables[0].Rows[0]["Photo"].ToString() != "" ? serverpath + "Images/Profile/" + ds.Tables[0].Rows[0]["Photo"].ToString() : serverpath + "Content/themes/Sites/images/avtar.png";
            }
            List<user> tusr = new List<user>();
            tusr = fillwithfriends(uid);



            var obj = Clients.User(uid);
            if (loggedInUsers.Count(x => x.userid == uid) == 0)
            {
                user tmpuser = new user();
                tmpuser.ConnectionId = id;
                tmpuser.name = _username;
                tmpuser.userid = uid;
                tmpuser.avator = dp;
                //tmpuser.ConnectionIds=new HashSet<string>();
                tmpuser.ConnectionIds.Add(id);

                loggedInUsers.Add(tmpuser);

                //loggedInUsers.Add(new user { ConnectionId = id, name = _username, userid = uid, avator = dp });                
                Clients.Caller.onConnected(id, _username, tusr, uid);
                //Clients.AllExcept(id).onNewUserConnected(id, _username, uid, dp);
                Clients.Others.onNewUserConnected(id, _username, uid, dp);

            }
            else if (loggedInUsers.Count(x => x.userid == uid) > 0)
            {
                user cuser = loggedInUsers.FirstOrDefault(x => x.userid == uid);
                lock (cuser.ConnectionIds)
                {
                    cuser.ConnectionIds.Add(id);
                }
                //Clients.Caller.onConnected(cuser.ConnectionId, _username, tusr, uid);
            }
            else
            {
                Clients.All.online(loggedInUsers);
            }
            //=====================Previous Code======================
            //var obj = Clients.User(uid);
            //if (loggedInUsers.Count(x => x.userid == uid) == 0)
            //{
            //    loggedInUsers.Add(new user { ConnectionId = id, name = _username, userid = uid, avator = dp });
            //    //Clients.Caller.onConnected(id, userName, loggedInUsers, uid);
            //    Clients.Caller.onConnected(id, _username, tusr, uid);
            //    Clients.AllExcept(id).onNewUserConnected(id, _username, uid, dp);
            //    //Clients.All.online(loggedInUsers);
            //}
            //else if (loggedInUsers.Count(x => x.userid == uid) > 0)
            //{
            //  user cuser=   loggedInUsers.FirstOrDefault(x => x.userid == uid);

            //  //Clients.Caller.onConnected(cuser.ConnectionId, _username, tusr, uid);
            //}
            //else
            //{
            //    Clients.All.online(loggedInUsers);
            //}
        }

        public void Logoutclient(string logout)
        {
            if (logout == "y")
            {
                var id = Context.ConnectionId;
                var item = loggedInUsers.FirstOrDefault(x => x.ConnectionIds.Contains(id));

                if (item != null)
                {
                    lock (item.ConnectionIds)
                    {
                        Clients.All.onUserDisconnected(item.userid, item.name);
                        loggedInUsers.Remove(item);
                        Clients.Others.newOfflineUser(item.id, item.name, item.userid, item.avator);
                    }
                }
            }

        }

        public void DeleteMsg(string msgid)
        {
            var id = Context.ConnectionId;
            var item = loggedInUsers.FirstOrDefault(x => x.ConnectionIds.Contains(id));
            if (item != null)
            {
                string userid = item.userid;
                ChatDataLayer dl = new ChatDataLayer();
                int i = dl.deletemsg(userid, msgid);
                if (i > 0)
                {
                    Clients.Clients(item.ConnectionIds.ToList()).removeMsg(msgid);
                }
            }
        }


    }

}