namespace M280_SampleApp
{
    partial class Form1
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            this.components = new System.ComponentModel.Container();
            this.btnCapture = new System.Windows.Forms.Button();
            this.groupBox1 = new System.Windows.Forms.GroupBox();
            this.labButtonImg = new System.Windows.Forms.Label();
            this.label2 = new System.Windows.Forms.Label();
            this.labBusyImg = new System.Windows.Forms.Label();
            this.label3 = new System.Windows.Forms.Label();
            this.labReadyImg = new System.Windows.Forms.Label();
            this.label1 = new System.Windows.Forms.Label();
            this.groupBox2 = new System.Windows.Forms.GroupBox();
            this.labSysBusyImg = new System.Windows.Forms.Label();
            this.label4 = new System.Windows.Forms.Label();
            this.labSysReadyImg = new System.Windows.Forms.Label();
            this.label7 = new System.Windows.Forms.Label();
            this.labUSBConImg = new System.Windows.Forms.Label();
            this.label9 = new System.Windows.Forms.Label();
            this.timCheckStatus = new System.Windows.Forms.Timer(this.components);
            this.picESEEK = new System.Windows.Forms.PictureBox();
            this.picImage = new System.Windows.Forms.PictureBox();
            this.groupBox3 = new System.Windows.Forms.GroupBox();
            this.chkTiltAdj = new System.Windows.Forms.CheckBox();
            this.txtASCData = new System.Windows.Forms.TextBox();
            this.groupBox1.SuspendLayout();
            this.groupBox2.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.picESEEK)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.picImage)).BeginInit();
            this.groupBox3.SuspendLayout();
            this.SuspendLayout();
            // 
            // btnCapture
            // 
            this.btnCapture.Location = new System.Drawing.Point(908, 505);
            this.btnCapture.Name = "btnCapture";
            this.btnCapture.Size = new System.Drawing.Size(193, 69);
            this.btnCapture.TabIndex = 1;
            this.btnCapture.Text = "Capture";
            this.btnCapture.UseVisualStyleBackColor = true;
            this.btnCapture.Click += new System.EventHandler(this.btnCapture_Click);
            // 
            // groupBox1
            // 
            this.groupBox1.Controls.Add(this.labButtonImg);
            this.groupBox1.Controls.Add(this.label2);
            this.groupBox1.Controls.Add(this.labBusyImg);
            this.groupBox1.Controls.Add(this.label3);
            this.groupBox1.Controls.Add(this.labReadyImg);
            this.groupBox1.Controls.Add(this.label1);
            this.groupBox1.Location = new System.Drawing.Point(908, 130);
            this.groupBox1.Name = "groupBox1";
            this.groupBox1.Size = new System.Drawing.Size(193, 120);
            this.groupBox1.TabIndex = 2;
            this.groupBox1.TabStop = false;
            this.groupBox1.Text = "Indicator";
            // 
            // labButtonImg
            // 
            this.labButtonImg.AutoSize = true;
            this.labButtonImg.Image = global::M280_SampleApp.Properties.Resources.gray3;
            this.labButtonImg.Location = new System.Drawing.Point(149, 84);
            this.labButtonImg.Name = "labButtonImg";
            this.labButtonImg.Size = new System.Drawing.Size(22, 13);
            this.labButtonImg.TabIndex = 5;
            this.labButtonImg.Text = "     ";
            // 
            // label2
            // 
            this.label2.AutoSize = true;
            this.label2.Location = new System.Drawing.Point(23, 84);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(78, 13);
            this.label2.TabIndex = 4;
            this.label2.Text = "Capture Button";
            // 
            // labBusyImg
            // 
            this.labBusyImg.AutoSize = true;
            this.labBusyImg.Image = global::M280_SampleApp.Properties.Resources.gray3;
            this.labBusyImg.Location = new System.Drawing.Point(149, 55);
            this.labBusyImg.Name = "labBusyImg";
            this.labBusyImg.Size = new System.Drawing.Size(22, 13);
            this.labBusyImg.TabIndex = 3;
            this.labBusyImg.Text = "     ";
            // 
            // label3
            // 
            this.label3.AutoSize = true;
            this.label3.Location = new System.Drawing.Point(46, 55);
            this.label3.Name = "label3";
            this.label3.Size = new System.Drawing.Size(54, 13);
            this.label3.TabIndex = 2;
            this.label3.Text = "Busy LED";
            // 
            // labReadyImg
            // 
            this.labReadyImg.AutoSize = true;
            this.labReadyImg.Image = global::M280_SampleApp.Properties.Resources.gray3;
            this.labReadyImg.Location = new System.Drawing.Point(149, 29);
            this.labReadyImg.Name = "labReadyImg";
            this.labReadyImg.Size = new System.Drawing.Size(22, 13);
            this.labReadyImg.TabIndex = 1;
            this.labReadyImg.Text = "     ";
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Location = new System.Drawing.Point(38, 29);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(62, 13);
            this.label1.TabIndex = 0;
            this.label1.Text = "Ready LED";
            // 
            // groupBox2
            // 
            this.groupBox2.Controls.Add(this.labSysBusyImg);
            this.groupBox2.Controls.Add(this.label4);
            this.groupBox2.Controls.Add(this.labSysReadyImg);
            this.groupBox2.Controls.Add(this.label7);
            this.groupBox2.Controls.Add(this.labUSBConImg);
            this.groupBox2.Controls.Add(this.label9);
            this.groupBox2.Location = new System.Drawing.Point(908, 11);
            this.groupBox2.Name = "groupBox2";
            this.groupBox2.Size = new System.Drawing.Size(193, 113);
            this.groupBox2.TabIndex = 3;
            this.groupBox2.TabStop = false;
            this.groupBox2.Text = "System Status";
            // 
            // labSysBusyImg
            // 
            this.labSysBusyImg.AutoSize = true;
            this.labSysBusyImg.Image = global::M280_SampleApp.Properties.Resources.gray3;
            this.labSysBusyImg.Location = new System.Drawing.Point(149, 80);
            this.labSysBusyImg.Name = "labSysBusyImg";
            this.labSysBusyImg.Size = new System.Drawing.Size(22, 13);
            this.labSysBusyImg.TabIndex = 5;
            this.labSysBusyImg.Text = "     ";
            // 
            // label4
            // 
            this.label4.AutoSize = true;
            this.label4.Location = new System.Drawing.Point(43, 80);
            this.label4.Name = "label4";
            this.label4.Size = new System.Drawing.Size(67, 13);
            this.label4.TabIndex = 4;
            this.label4.Text = "System Busy";
            // 
            // labSysReadyImg
            // 
            this.labSysReadyImg.AutoSize = true;
            this.labSysReadyImg.Image = global::M280_SampleApp.Properties.Resources.gray3;
            this.labSysReadyImg.Location = new System.Drawing.Point(149, 55);
            this.labSysReadyImg.Name = "labSysReadyImg";
            this.labSysReadyImg.Size = new System.Drawing.Size(22, 13);
            this.labSysReadyImg.TabIndex = 3;
            this.labSysReadyImg.Text = "     ";
            // 
            // label7
            // 
            this.label7.AutoSize = true;
            this.label7.Location = new System.Drawing.Point(35, 55);
            this.label7.Name = "label7";
            this.label7.Size = new System.Drawing.Size(75, 13);
            this.label7.TabIndex = 2;
            this.label7.Text = "System Ready";
            // 
            // labUSBConImg
            // 
            this.labUSBConImg.AutoSize = true;
            this.labUSBConImg.Image = global::M280_SampleApp.Properties.Resources.gray3;
            this.labUSBConImg.Location = new System.Drawing.Point(149, 29);
            this.labUSBConImg.Name = "labUSBConImg";
            this.labUSBConImg.Size = new System.Drawing.Size(22, 13);
            this.labUSBConImg.TabIndex = 1;
            this.labUSBConImg.Text = "     ";
            // 
            // label9
            // 
            this.label9.AutoSize = true;
            this.label9.Location = new System.Drawing.Point(38, 29);
            this.label9.Name = "label9";
            this.label9.Size = new System.Drawing.Size(72, 13);
            this.label9.TabIndex = 0;
            this.label9.Text = "USB Connect";
            // 
            // picESEEK
            // 
            this.picESEEK.Image = global::M280_SampleApp.Properties.Resources.e_seek_top_logo;
            this.picESEEK.InitialImage = null;
            this.picESEEK.Location = new System.Drawing.Point(908, 420);
            this.picESEEK.Name = "picESEEK";
            this.picESEEK.Size = new System.Drawing.Size(193, 74);
            this.picESEEK.TabIndex = 4;
            this.picESEEK.TabStop = false;
            // 
            // picImage
            // 
            this.picImage.Location = new System.Drawing.Point(12, 11);
            this.picImage.Name = "picImage";
            this.picImage.Size = new System.Drawing.Size(882, 572);
            this.picImage.TabIndex = 0;
            this.picImage.TabStop = false;
            // 
            // groupBox3
            // 
            this.groupBox3.Controls.Add(this.chkTiltAdj);
            this.groupBox3.Location = new System.Drawing.Point(908, 266);
            this.groupBox3.Name = "groupBox3";
            this.groupBox3.Size = new System.Drawing.Size(193, 60);
            this.groupBox3.TabIndex = 5;
            this.groupBox3.TabStop = false;
            this.groupBox3.Text = "Option";
            // 
            // chkTiltAdj
            // 
            this.chkTiltAdj.AutoSize = true;
            this.chkTiltAdj.Location = new System.Drawing.Point(30, 19);
            this.chkTiltAdj.Name = "chkTiltAdj";
            this.chkTiltAdj.Size = new System.Drawing.Size(120, 17);
            this.chkTiltAdj.TabIndex = 0;
            this.chkTiltAdj.Text = "Auto Tilt Adjustment";
            this.chkTiltAdj.UseVisualStyleBackColor = true;
            // 
            // txtASCData
            // 
            this.txtASCData.Location = new System.Drawing.Point(908, 333);
            this.txtASCData.Multiline = true;
            this.txtASCData.Name = "txtASCData";
            this.txtASCData.Size = new System.Drawing.Size(193, 81);
            this.txtASCData.TabIndex = 6;
            // 
            // Form1
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(1113, 586);
            this.Controls.Add(this.txtASCData);
            this.Controls.Add(this.groupBox3);
            this.Controls.Add(this.picESEEK);
            this.Controls.Add(this.groupBox2);
            this.Controls.Add(this.groupBox1);
            this.Controls.Add(this.btnCapture);
            this.Controls.Add(this.picImage);
            this.Name = "Form1";
            this.Text = "M280 Sample App";
            this.groupBox1.ResumeLayout(false);
            this.groupBox1.PerformLayout();
            this.groupBox2.ResumeLayout(false);
            this.groupBox2.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)(this.picESEEK)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.picImage)).EndInit();
            this.groupBox3.ResumeLayout(false);
            this.groupBox3.PerformLayout();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.PictureBox picImage;
        private System.Windows.Forms.Button btnCapture;
        private System.Windows.Forms.GroupBox groupBox1;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.Label labReadyImg;
        private System.Windows.Forms.Label label3;
        private System.Windows.Forms.Label labBusyImg;
        private System.Windows.Forms.Label label2;
        private System.Windows.Forms.Label labButtonImg;
        private System.Windows.Forms.GroupBox groupBox2;
        private System.Windows.Forms.Label labSysReadyImg;
        private System.Windows.Forms.Label label7;
        private System.Windows.Forms.Label labUSBConImg;
        private System.Windows.Forms.Label label9;
        private System.Windows.Forms.Timer timCheckStatus;
        private System.Windows.Forms.PictureBox picESEEK;
        private System.Windows.Forms.Label labSysBusyImg;
        private System.Windows.Forms.Label label4;
        private System.Windows.Forms.GroupBox groupBox3;
        private System.Windows.Forms.CheckBox chkTiltAdj;
        private System.Windows.Forms.TextBox txtASCData;
    }
}

