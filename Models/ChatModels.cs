using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Web;


namespace Models
{
    public class Login {
        [Required]
        [StringLength(100, ErrorMessage = "The {0} must be at least {2} characters long.", MinimumLength = 4)]        
        [Display(Name = "Name")]
        public string UserNick { get; set; }
    }
  public enum Status
    {
        Online,
        Away,
        Busy,
        Offline
    }
    public class Css
    {
        public string color { get; set; }
        public string underline { get; set; }
        public string fstyle { get; set; }
        public string italic { get; set; }
        public string bold { get; set; }
    }


    public class user
    {
        //id, name, type, fontName, fontSize, fontColor, sex, age, friendsList, status, memberType

       public  string ConnectionId { get; set; }
        public int id { get; set; }
        public string userid { get; set; }
        public string name { get; set; }
        public List<user> friendsList { get; set; }
        public string fontName { get; set; }
        public string fontSize { get; set; }
        public string fontColor { get; set; }
        public string sex { get; set; }
        public int age { get; set; }
        public string status { get; set; }
        public string memberType { get; set; }
        public string avator { get; set; }
        public string IsOnline { get; set; }
        public HashSet<string> ConnectionIds = new HashSet<string>();

        //public user Login(string UserName)
        //{ 


        //}

    }
    public class UsersRestricted
    {

        public int id { get; set; }
        public string name { get; set; }
        public string roomName { get; set; }
        public Restriction restriction { get; set; }

        public DateTime time { get; set; }

        public string restrictekBy { get; set; }
    }
    public  enum Restriction
    {
        BAN, MUTE, KICK
    }

    public class MessageModel
    {
        [Display(Name = "Msg_id")]
        public string Msg_id { get; set; }

        [Required]
        [Display(Name = "Msg From User Id")]
        public string Msg_From_User_Id { get; set; }

        [Required]
        [Display(Name = "Msg To User Id")]
        public string Msg_To_User_Id { get; set; }

        //[Display(Name = "Subject")]
        //public string Subject { get; set; }

        [Required]
        [Display(Name = "Message")]
        public string Message { get; set; }

        [Display(Name = "Is Read")]
        public string Is_Read { get; set; }

        [Display(Name = "Msg Date")]
        public string Msg_Date { get; set; }

        [Display(Name = "Msg Status")]
        public string Msg_Status { get; set; }


        public string IsPublic { get; set; }
    }

  }