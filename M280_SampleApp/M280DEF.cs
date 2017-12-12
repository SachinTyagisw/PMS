using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Drawing;
using System.Drawing.Imaging;

namespace M280_SampleApp
{
    class M280DEF
    {
        // Software Version
        public const string SWver = "3.01.00";
        public const string ProName = "M280 Sample App";

        // PID, VID
        //public const ushort USB_PID = 0x1003;
        //public const ushort USB_VID = 0x04b4; //Old Version
        public const ushort USB_PID = 0x0280;
        public const ushort USB_VID = 0x28A6;

        // Define Command
        public const byte CMD_ST_CAP = 0xDA;
        public const byte CMD_SET_ILLUMIN = 0xE0;
        public const byte CMD_INIT_CAMERA = 0xE1;
        public const byte CMD_GET_STATE = 0xEA;
        public const byte CMD_GET_VERSION = 0xEB;
        public const byte CMD_GET_IMGINFO = 0xEE;
       
        // F/W version length
        public const byte MAX_CNUM_APP1 = 10;
        // Image Info size 20 byte
        public const byte IMGINFO_SIZE = 20;

        // Image download 
        //public const PixelFormat PixFormat = PixelFormat.Format24bppRgb;
        public const PixelFormat PixFormat = PixelFormat.Format16bppRgb565;
      
        //public const int Packet_Xfer = 12;    // Old 512 * 12 = 6144
        public const int Packet_Xfer = 24;      // New 512 * 24 = 12288
        public const int Image_Xsize = 1024;
        public const int Image_Ysize = 768;

        // Status 
        public const int STATUS_SIZE = 2;
        public const ushort stat_ReadyLED = 1 << 0;
        public const ushort stat_BusyLED = 1 << 1;
        public const ushort stat_CardDet = 1 << 2;
        public const ushort stat_CapDet = 1 << 3;
        public const ushort stat_CamInit = 1 << 4;
        public const ushort stat_SysBusy = 1 << 5;

        public const ushort stat_EngineEr = 1 << 7;
        public const ushort stat_EepromEr = 1 << 8;
        public const ushort stat_FPGAEr = 1 << 9;
        public const ushort StatusGetInterval = 100;  // 100mS

        // Others...
        public const ushort ON = 1;
        public const ushort OFF = 0;
        public const int TRANSFER_TIMEOUT = 1500;   //  Wait for the transfer to complete. 
    }

    class M280IMGDEF
    {
        public const int IMG_CARDSZ_X = 892;
        public const int IMG_CARDSZ_Y = 564;
        public const byte IMG_ANGLE = 0xFF / 2;
    }
}
