using System;
using System.Drawing;
using System.Drawing.Drawing2D;

namespace M280_SampleApp
{
    public sealed class Utilities
    {
        private Utilities()
        {
        }
        /// <summary>
        /// Creates a new Image containing the same image only rotated
        /// </summary>
        /// <param name="image">The <see cref="System.Drawing.Image"/> to rotate</param>
        /// <param name="angle">The amount to rotate the image, clockwise, in degrees</param>
        /// <returns>A new <see cref="System.Drawing.Bitmap"/> of the same size rotated.</returns>
        /// <exception cref="System.ArgumentNullException">Thrown if <see cref="image"/> is null.</exception>
        public static Bitmap RotateImage(Bitmap image, float angle)
        {
            return RotateImage(image, new PointF((float)image.Width / 2, (float)image.Height / 2), angle);
        }

        /// <summary>
        /// Creates a new Image containing the same image only rotated
        /// </summary>
        /// <param name="image">The <see cref="System.Drawing.Image"/> to rotate</param>
        /// <param name="offset">The position to rotate from.</param>
        /// <param name="angle">The amount to rotate the image, clockwise, in degrees</param>
        /// <returns>A new <see cref="System.Drawing.Bitmap"/> of the same size rotated.</returns>
        /// <exception cref="System.ArgumentNullException">Thrown if <see cref="image"/> is null.</exception>
        public static Bitmap RotateImage(Bitmap image, PointF offset, float angle)
        {
            if (image == null)
                throw new ArgumentNullException("image");

            //create a new empty bitmap to hold rotated image
            Bitmap rotatedBmp = new Bitmap(image.Width, image.Height, M280DEF.PixFormat);
            rotatedBmp.SetResolution(image.HorizontalResolution, image.VerticalResolution);

            //make a graphics object from the empty bitmap
            Graphics g = Graphics.FromImage(rotatedBmp);

            //Put the rotation point in the center of the image
            g.TranslateTransform(offset.X, offset.Y);

            //rotate the image
            g.RotateTransform(angle);

            //move the image back
            g.TranslateTransform(-offset.X, -offset.Y);

            //draw passed in image onto graphics object
            g.DrawImage(image, new PointF(0, 0));

            return rotatedBmp;
        }


        /// <summary>
        /// Creates a new Image containing the same image only rotated
        /// </summary>
        /// <param name="image">The <see cref="System.Drawing.Image"/> to rotate</param>
        /// <param name="offset">The position to rotate from.</param>
        /// <param name="bAngle">The amount to rotate the image, in converted byte</param>
        /// <returns>A new <see cref="System.Drawing.Bitmap"/> of the same size rotated.</returns>
        /// <exception cref="System.ArgumentNullException">Thrown if <see cref="image"/> is null.</exception>
        public static Bitmap RotateImage(Bitmap image, PointF offset, byte bAngle)
        {
            float angle;
            if (image == null)
                throw new ArgumentNullException("image");

            //convert bAngle to angle
            if (bAngle > 0xff / 2)
            {
                angle = (float)((bAngle - 0xff / 2) * 0.1);
            }
            else if (bAngle == 0xff / 2)
            {
                angle = 0;
            }
            else
            {
                angle = -(float)((0xff / 2 - bAngle) * 0.1);
            }
            //create a new empty bitmap to hold rotated image
            Bitmap rotatedBmp = new Bitmap(image.Width, image.Height, M280DEF.PixFormat);
            rotatedBmp.SetResolution(image.HorizontalResolution, image.VerticalResolution);

            //make a graphics object from the empty bitmap
            Graphics g = Graphics.FromImage(rotatedBmp);

            //Put the rotation point in the center of the image
            g.TranslateTransform(offset.X, offset.Y);

            //rotate the image
            g.RotateTransform(angle);

            //move the image back
            g.TranslateTransform(-offset.X, -offset.Y);

            //draw passed in image onto graphics object
            g.DrawImage(image, new PointF(0, 0));

            return rotatedBmp;
        }

        public static byte ConverDEGtoByte(float angle)
        {
            byte byt;
            if (angle > 0)
            {
                if (Math.Round(angle * 10) > 0xff / 2)
                {
                    byt = 0xff;
                }
                else
                {
                    byt = (byte)(0xff / 2 + Math.Round(angle * 10));
                }
            }
            else
            {
                angle = Math.Abs(angle);
                if (Math.Round(angle * 10) > 0xff / 2)
                {
                    byt = 0x0;
                }
                else
                {
                    byt = (byte)(0xff / 2 - Math.Round(angle * 10));
                }
            }
            return byt;
        }
    }
}
