using Microsoft.AspNet.SignalR;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace PrimePMSService
{
    public class MyHub : Hub
    {
        

        public void SendGuestObject(GuestDetail guest)
        {
            Clients.All.sendGuestObject(guest);
        }

        public void SendGuestImageObject(GuestImages img)
        {
            Clients.All.sendGuestImageObject(img);
        }

        public override Task OnConnected()
        {
            //Console.WriteLine("Hub OnConnected {0}\n", Context.ConnectionId);
            return (base.OnConnected());
        }

    }
}
