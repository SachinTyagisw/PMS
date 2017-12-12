using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Drawing.Imaging;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using System.Threading;
using CyUSB;
using System.IO.Ports;
using Microsoft.Win32;
using Microsoft.AspNet.SignalR;

namespace M280_SampleApp
{
    //Delegate Declaration - Sachin
    public delegate void serialPortFunc(string recvStr);

    public partial class Form1 : Form
    {
        USBDeviceList usbDevices;
        CyUSBDevice MyDevice;
        CyBulkEndPoint inEndpoint = null;
        CyControlEndPoint ep0 = null;

        //Declare Seral Port
        SerialPort serPort =new SerialPort();
        
        int BufNum = 0;
        int BufSz;
        int QueueSz;
        int Successes;
        int Failures;
        int TotalPixSize;
        double XferBytes;
        bool bRunning;
        bool bInitM280;
        bool bSysBusy;
        byte[][] DataBuf;
        byte[] M280Status = new byte[M280DEF.STATUS_SIZE];

        // Image Info
        int DatumPos_sX = 0, DatumPos_sY = 0, CropSize_X = 0, CropSize_Y = 0, AngleInfo = 0;

        Bitmap CroppedImage;

        // Start capture Thread
        Thread tStartCap;

        // These are needed to close the app from the Thread exception(exception handling)
        delegate void ExceptionCallback();
        ExceptionCallback handleException;

        // These are  needed for Thread to make image view function
        delegate void Image_View();
        Image_View Img_View;

        public Form1()
        {
            InitializeComponent();

            // For USB Camera
            // Create the list of USB devices attached to the CyUSB.sys driver.
            usbDevices = new USBDeviceList(CyConst.DEVICES_CYUSB);

            // Setup the callback routine for NullReference exception handling
            handleException = new ExceptionCallback(ThreadException);

            // Setup the callback routine for Image view from M280 board
            Img_View = new Image_View(ImageView);

            //Assign event handlers for device attachment and device removal.
            usbDevices.DeviceAttached += new EventHandler(usbDevices_DeviceAttached);
            usbDevices.DeviceRemoved += new EventHandler(usbDevices_DeviceRemoved);

            //Associate handler with DataReceived Event - Sachin
            serPort.DataReceived +=serPort_DataReceived;

            // Set Form name
            this.Text = M280DEF.ProName + " - V" + M280DEF.SWver;

            //Set and search the device with VID-PID 04b4-1003 and if found, selects the end point
            SetDevice();

            //Initialize value
            if (M280DEF.PixFormat == PixelFormat.Format16bppRgb565)
            {
                TotalPixSize = M280DEF.Image_Xsize * M280DEF.Image_Ysize * 2;
            }
            else if (M280DEF.PixFormat == PixelFormat.Format24bppRgb)
            {
                TotalPixSize = M280DEF.Image_Xsize * M280DEF.Image_Ysize * 3;
            }

            if ((TotalPixSize % (512 * M280DEF.Packet_Xfer)) != 0)
            {
                MessageBox.Show("Please check pixel size!");
            }

            this.BufNum = TotalPixSize / (512 * M280DEF.Packet_Xfer);
            this.timCheckStatus.Tick += new EventHandler(CheckState_Tick);
            this.timCheckStatus.Interval = M280DEF.StatusGetInterval;
            this.bInitM280 = false;
            this.bSysBusy = false;
            openPort();
        }
        /*Summary
          Search the device with VID-PID 04b4-1003 and if found, select the end point
       */

        private void openPort()
        {
            if (this.serPort.IsOpen)
            {
                this.serPort.Close();
            }
                StopBits one = StopBits.One;
                Parity none = Parity.None;
                Handshake requestToSend = Handshake.None;
                //RegistryKey key2 = Registry.CurrentUser.OpenSubKey("Software", true).OpenSubKey("M280DEMO", true);
                //if (key2 != null)
                //{
                //    key2.SetValue("Port", "COM3");
                //    key2.SetValue("Baud", 9600);
                //    key2.SetValue("DataBits", 8);
                //    key2.SetValue("Parity", 0);
                //    key2.SetValue("Flow", 0);
                //    key2.SetValue("Stop", 0);
                //    key2.Close();
                //}
                this.serPort.PortName = "COM3";
                this.serPort.BaudRate = 9600;
                this.serPort.DataBits = 8;
                this.serPort.StopBits = one;
                this.serPort.Parity = none;
                this.serPort.Handshake = requestToSend;
                this.serPort.Open();
        }

        private void SetDevice()
        {
            MyDevice = usbDevices[M280DEF.USB_VID, M280DEF.USB_PID] as CyUSBDevice;
           
            if (MyDevice != null)
            {
                // USB High Speed Check
                /*
                if (MyDevice.bHighSpeed == false)
                {
                    MessageBox.Show("M280 supports USB2.0 only.");
                    MyDevice = null;
                    inEndpoint = null;
                    ep0 = null;
                } 
                else
                */
                if (inEndpoint == null)
                {
                    // Set the IN and OUT endpoints           
                    inEndpoint = MyDevice.EndPointOf(0x86) as CyBulkEndPoint;
                    ep0 = MyDevice.ControlEndPt;
                    // Set time out
                    inEndpoint.TimeOut = M280DEF.TRANSFER_TIMEOUT;
                    ep0.TimeOut = M280DEF.TRANSFER_TIMEOUT;
                    // Get Image Info 
                    GetImageInfo();
                    // Initialize Camera module
                    SendCommand(M280DEF.CMD_INIT_CAMERA, 0, 0);
                    // Turn on USB connected LED
                    labUSBConImg.Image = global::M280_SampleApp.Properties.Resources.green3;
                    // Start Check status
                    this.timCheckStatus.Start();
                }
            }
            else
            {
                inEndpoint = null;
                ep0 = null;

                // Turn off USB connected LED
                labUSBConImg.Image = global::M280_SampleApp.Properties.Resources.gray3;
                labSysReadyImg.Image = global::M280_SampleApp.Properties.Resources.gray3;
                labReadyImg.Image = global::M280_SampleApp.Properties.Resources.gray3;
                labBusyImg.Image = global::M280_SampleApp.Properties.Resources.gray3;
                labButtonImg.Image = global::M280_SampleApp.Properties.Resources.gray3;

                // Stop checking status thread
                this.timCheckStatus.Stop();
                this.bInitM280 = false;
                this.bSysBusy = false;
            }
        }
        void usbDevices_DeviceRemoved(object sender, EventArgs e)
        {
            MyDevice = null;
            inEndpoint = null;
            SetDevice();
        }
        /*Summary
          This is the event handler for device attachment. This method  searches for the device with 
          VID-PID 04b4-1003
       */
        void usbDevices_DeviceAttached(object sender, EventArgs e)
        {
            SetDevice();
        }
        /*Summary
          Start Image capture
        */
        private void btnCapture_Click(object sender, EventArgs e)
        {
            if (MyDevice == null || ep0 == null || inEndpoint == null) return;
            if (bRunning == true || this.bInitM280 == false || this.bSysBusy == true) return;

            bRunning = true;
          
            BufSz = inEndpoint.MaxPktSize * M280DEF.Packet_Xfer;        
            QueueSz = BufNum;

            inEndpoint.XferSize = BufSz;

            // Initializing Data Buffer
            DataBuf = new byte[TotalPixSize / BufSz][];
            for (int i = 0; i < (TotalPixSize / BufSz); i++)
            {
                DataBuf[i] = new byte[BufSz];
            }

            tStartCap = new Thread(new ThreadStart(XferThread));
            tStartCap.IsBackground = true;
            tStartCap.Priority = ThreadPriority.Highest;
            tStartCap.Start();
            // Send Start capture command to M280
            SendCommand(M280DEF.CMD_ST_CAP, 0, 0);
        }

        /*Summary
         Data Xfer Thread entry point. Starts the thread on Start Button click 
        */
        public unsafe void XferThread()
        {
            // Setup the queue buffers
            byte[][] cmdBufs = new byte[QueueSz][];
            byte[][] xferBufs = new byte[QueueSz][];
            byte[][] ovLaps = new byte[QueueSz][];
            ISO_PKT_INFO[][] pktsInfo = new ISO_PKT_INFO[QueueSz][];
            int xStart = 0;

            try
            {
                LockNLoad(ref xStart, cmdBufs, xferBufs, ovLaps, pktsInfo);
            }
            catch (NullReferenceException e)
            {
                // This exception gets thrown if the device is unplugged 
                // while we're streaming data
                e.GetBaseException();
                this.Invoke(handleException);
            }
        }

        /*Summary
          This is a recursive routine for pinning all the buffers used in the transfer in memory.
            It will get recursively called QueueSz times.  On the QueueSz_th call, it will call
            XferData, which will loop, transferring data.
       */
        public unsafe void LockNLoad(ref int j, byte[][] cBufs, byte[][] xBufs, byte[][] oLaps, ISO_PKT_INFO[][] pktsInfo)
        {
            // Allocate one set of buffers for the queue
            cBufs[j] = new byte[CyConst.SINGLE_XFER_LEN];
            xBufs[j] = new byte[BufSz];
            oLaps[j] = new byte[20];
           //pktsInfo[j] = new ISO_PKT_INFO[PPX];
            pktsInfo[j] = new ISO_PKT_INFO[M280DEF.Packet_Xfer];
           
            fixed (byte* tL0 = oLaps[j], tc0 = cBufs[j], tb0 = xBufs[j])  // Pin the buffers in memory
            {
                OVERLAPPED* ovLapStatus = (OVERLAPPED*)tL0;
                ovLapStatus->hEvent = (IntPtr)PInvoke.CreateEvent(0, 0, 0, 0);

                // Pre-load the queue with a request
                int len = BufSz;
                inEndpoint.BeginDataXfer(ref cBufs[j], ref xBufs[j], ref len, ref oLaps[j]);

                j++;

                if (j < QueueSz)
                    LockNLoad(ref j, cBufs, xBufs, oLaps, pktsInfo);  // Recursive call to pin next buffers in memory
                else
                {
                    XferData(cBufs, xBufs, oLaps, pktsInfo);          // All loaded. Let's go!
                }
            }
        }

        /*Summary
         Called at the end of recursive method, LockNLoad().
         XferData() implements the infinite transfer loop
       */
        public unsafe void XferData(byte[][] cBufs, byte[][] xBufs, byte[][] oLaps, ISO_PKT_INFO[][] pktsInfo)
        {
            int k = 0;
            int len = 0;
            int pDataBF = 0;

            Successes = 0;
            Failures = 0;
            XferBytes = 0;

            for (; bRunning; )
            {
                // WaitForXfer
                fixed (byte* tmpOvlap = oLaps[k])
                {
                    OVERLAPPED* ovLapStatus = (OVERLAPPED*)tmpOvlap;
                    if (!inEndpoint.WaitForXfer(ovLapStatus->hEvent, 500))
                    {
                        inEndpoint.Abort();
                        PInvoke.WaitForSingleObject(ovLapStatus->hEvent, 500);
                    }
                }

                // FinishDataXfer
                if (inEndpoint.FinishDataXfer(ref cBufs[k], ref xBufs[k], ref len, ref oLaps[k]))
                {
                    XferBytes += len;
                    Successes++;
                    Array.Copy(xBufs[k], 0, DataBuf[pDataBF], 0, len);
                    pDataBF++;
                }
                else
                {
                    Failures++;
                }
                k++;
                if (k == QueueSz)  // Finish
                {
                    k = 0;
                    Thread.Sleep(1);
                    if (Failures == 0)
                    {
                        this.Invoke(Img_View);
                    }
                    else
                    {
                       // Scanner busy
                       MessageBox.Show("Scanner Busy! Please Try again.");
                    }
                    bRunning = false;
                }
            }
        }
        /*Summary
          Send command to M280 device
        */
        public bool SendCommand(byte Cmd, ushort val, ushort index)
        {
            bool ret = false;
            if (MyDevice == null || ep0 == null) return ret;

            ep0.Target = CyConst.TGT_DEVICE;
            ep0.ReqType = CyConst.REQ_VENDOR;
            ep0.Direction = CyConst.DIR_TO_DEVICE;
            ep0.ReqCode = Cmd;
            ep0.Value = val;
            ep0.Index = index;
            int len = 0;
            byte[] buf = new byte[1];
            ret = ep0.XferData(ref buf, ref len);
            return ret;
        }
        /*Summary
         Send Command and Get Data from M280 device
        */
        public bool ReadCommand(byte Cmd, ref byte[] Read, ref int Len, ushort val, ushort index)
        {
            bool ret = false;
            if (MyDevice == null || ep0 == null) return ret;
            ep0.Target = CyConst.TGT_DEVICE;
            ep0.ReqType = CyConst.REQ_VENDOR;
            ep0.Value = val;
            ep0.Index = index;
            ep0.ReqCode = Cmd;
            ret = ep0.Read(ref Read, ref Len);
            return ret;
        }

        private void CheckState_Tick(object sender, EventArgs e)
        {
            this.timCheckStatus.Stop();

            int len = M280DEF.STATUS_SIZE;
            UInt16 StatusValue;

            if (MyDevice == null || ep0 == null) return;

            this.ReadCommand(M280DEF.CMD_GET_STATE, ref this.M280Status, ref len, 0, 0);

            // Parsing
            StatusValue = BitConverter.ToUInt16(M280Status, 0);

            // Check Push button
            if ((StatusValue & M280DEF.stat_CapDet) == M280DEF.stat_CapDet)
            {
                labButtonImg.Image = global::M280_SampleApp.Properties.Resources.green3;
                this.btnCapture_Click(0, null);
            }
            else
            {
                labButtonImg.Image = global::M280_SampleApp.Properties.Resources.gray3;
            }
            
            // Check Busy LED
            if ((StatusValue & M280DEF.stat_BusyLED) == M280DEF.stat_BusyLED)
            {
                labBusyImg.Image = global::M280_SampleApp.Properties.Resources.red3;
            }
            else
            {
                labBusyImg.Image = global::M280_SampleApp.Properties.Resources.gray3;
            }

            // Check Ready LED
            if ((StatusValue & M280DEF.stat_ReadyLED) == M280DEF.stat_ReadyLED)
            {
                labReadyImg.Image = global::M280_SampleApp.Properties.Resources.green3;
            }
            else
            {
                labReadyImg.Image = global::M280_SampleApp.Properties.Resources.gray3;
            }

            // Check System Ready
            if ((StatusValue & M280DEF.stat_CamInit) == M280DEF.stat_CamInit)
            {
                labSysReadyImg.Image = global::M280_SampleApp.Properties.Resources.green3;
                this.bInitM280 = true;
            }
            else
            {
                labSysReadyImg.Image = global::M280_SampleApp.Properties.Resources.gray3;
                this.bInitM280 = false;
            }

            // Check System Busy
            if ((StatusValue & M280DEF.stat_SysBusy) == M280DEF.stat_SysBusy)
            {
                labSysBusyImg.Image = global::M280_SampleApp.Properties.Resources.green3;
                this.bSysBusy = true;
            }
            else
            {
                labSysBusyImg.Image = global::M280_SampleApp.Properties.Resources.gray3;
                this.bSysBusy = false;
            }

            this.timCheckStatus.Start();
        }
         /*Summary
        Get Image infomation from M280 device.
        */
        public void GetImageInfo()
        {
            if (MyDevice == null || ep0 == null) return;
            int len = M280DEF.IMGINFO_SIZE;
            byte[] dta = new byte[len];
      
            if (this.ReadCommand(M280DEF.CMD_GET_IMGINFO, ref dta, ref len, 0, 0) == true)
            {
                // Convert Endian
                Array.Reverse(dta, 0, 2);   // DatumPos_sX
                Array.Reverse(dta, 2, 2);   // DatumPos_sY
                Array.Reverse(dta, 4, 2);   // CropSize_X
                Array.Reverse(dta, 6, 2);   // CropSize_Y
                Array.Reverse(dta, 14, 2);  // DPI

                this.DatumPos_sX = BitConverter.ToUInt16(dta, 0);
                this.DatumPos_sY = BitConverter.ToUInt16(dta, 2);
                this.CropSize_X = BitConverter.ToUInt16(dta, 4);
                this.CropSize_Y = BitConverter.ToUInt16(dta, 6);
                this.AngleInfo = (int)dta[13];
            }
            else
            {
                // Cann't find Image Info
                MessageBox.Show("Can not find Image Info Please check Firmware version!");
                this.DatumPos_sX = (M280DEF.Image_Xsize - M280IMGDEF.IMG_CARDSZ_X) / 2;
                this.DatumPos_sY = (M280DEF.Image_Ysize - M280IMGDEF.IMG_CARDSZ_Y) / 2;
                this.CropSize_X = M280IMGDEF.IMG_CARDSZ_X;
                this.CropSize_Y = M280IMGDEF.IMG_CARDSZ_Y;
                this.AngleInfo = (int)M280IMGDEF.IMG_ANGLE;
            }
        }
        /*Summary
        The callback routine delegated to handleException.
        */
        public void ThreadException()
        {
            bRunning = false;
            tStartCap = null;
            this.timCheckStatus.Dispose();
        }

        /*Summary
       The callback routine delegated to Image view
       */
        public void ImageView()
        {
            Bitmap SourceImage = CreateBitmap(M280DEF.Image_Xsize, M280DEF.Image_Ysize, M280DEF.PixFormat);

            // Adjust Angle
            if (chkTiltAdj.Checked == true)
            {
                SourceImage = Utilities.RotateImage(SourceImage, new PointF((float)(this.DatumPos_sX + this.CropSize_X / 2),
                                            (float)(this.DatumPos_sY + this.CropSize_Y / 2)), (byte)this.AngleInfo);
            }

            // Crop Image
            Rectangle CropRect = new Rectangle(this.DatumPos_sX, this.DatumPos_sY, 
                                                this.CropSize_X, this.CropSize_Y);
            this.CroppedImage = SourceImage.Clone(CropRect, M280DEF.PixFormat);

            SourceImage.Dispose();
            this.picImage.Image = this.CroppedImage;
        }

        /*Summary
          The CreateBitmap routine.
        */
        public Bitmap CreateBitmap(int Width, int Height, PixelFormat Pfmt)
        {
            if (Pfmt == PixelFormat.Format24bppRgb)
            {
                if ((Width * Height * 3) != (TotalPixSize))
                    return null;
            }
            else if (Pfmt == PixelFormat.Format16bppRgb565)
            {
                if ((Width * Height * 2) != (TotalPixSize))
                    return null;
            }
            else
            {
                return null;
            }

            try
            {
                Bitmap Canvas = new Bitmap(Width, Height, Pfmt);
                BitmapData CanvasData = Canvas.LockBits(new Rectangle(0, 0, Width, Height),
                                    ImageLockMode.WriteOnly, Pfmt);

                unsafe
                {
                    byte* Ptr = (byte*)CanvasData.Scan0.ToPointer();

                    for (int Y = 0; Y < TotalPixSize / BufSz; Y++)
                    {

                        for (int X = 0; X < BufSz; X++)
                        {
                            // Swap Data
                            if (X % 2 == 1)
                            {
                                *Ptr = DataBuf[Y][X];
                                Ptr++;
                                *Ptr = DataBuf[Y][X - 1];
                                Ptr++;
                            }
                        }
                    }
                }
                Canvas.UnlockBits(CanvasData);
                return Canvas;

            }
            catch (Exception)
            {
                return null;
            }

        }

        //Handler for DataReceived - Sachin
        private void serPort_DataReceived(object sender, SerialDataReceivedEventArgs e)
        {
            string str = this.serPort.ReadExisting();
            if (str.Length != 0)
                {
                    base.Invoke(new serialPortFunc(this.dataReceived), new object[] { str });
                }
        }


        //Proccess Received Data - Sachin
        private void dataReceived(string recvStr)
        {
            //String to capture the data in ASCII format
            string txtASCData = string.Empty;
                string text = recvStr.Replace("\n", ".").Replace("\r", ".");
                char[] chArray = recvStr.ToCharArray();
                text = "";
                for (int i = 0; i < chArray.Length; i++)
                {
                    if ((chArray[i] >= '!') && (chArray[i] <= '~'))
                    {
                        text = text + chArray[i].ToString();
                    }
                    else
                    {
                        text = text + ".";
                    }
                }

                txtASCData +=text;

            IHubContext hubContext = GlobalHost.ConnectionManager.GetHubContext<MyHub>();

            var vv = new GuestDetail
            {
                Title = "Mr.",
                FirstName = "Ankit",
                LastName = "Bansal",
                Address = "Near Iffco chok",
                City = "Gurgaon",
                Country = "India",
                EmailId = "ankit@gmail.com",
                PhoneNo = "8588892245",
                State = "Haryana",
                Zip = "110038"
            };

            hubContext.Clients.All.sendGuestObject(vv);
        }
    }
}
