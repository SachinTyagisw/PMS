using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace PMS.Resources.Common.Constants
{
    public class RegExConstants
    {
        public const string NumericRegExWithEmptyValue = @"^(?:\d{1})?$";
        public const string NumericRegEx = @"^([0-9]+)$";
        public const string AlphaNumericRegEx = "^[0-9a-zA-Z]+$";
        public const string AlphaNumericAllowSpaceRegEx = "^[0-9a-zA-Z ][0-9a-zA-Z ']*$";
        public const string AlphaNumericAllowSpaceAndSingleQuoteRegEx = "^[0-9a-zA-Z][0-9a-zA-Z ']*$";
        public const string UnsignedByteRegEx = @"^([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])$";
        public const string AlphabetRegEx = @"^[a-zA-Z]+$";
        public const string AlphaNumericStartWithAlphabetRegEx = "^([a-zA-Z][0-9a-zA-Z]*)$";
        public const string EmailRegEx = @"^[a-zA-Z0-9]+[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(\.(?:[a-zA-Z](?:[a-zA-Z]{0,61}[a-zA-Z])?)+)+$";
        public const string ExactlyFourDigitRegex = @"^\d{4}$";
        public const string ExactlyFiveDigitRegex = @"^\d{5}$";
        public const string ExactlyTenDigitRegex = @"^\d{10}$";
        public const string HomePhoneRegex = "^[0-9]{3,11}$";
        public const string WorkPhoneRegex = "^[0-9]{3,17}$";
        public const string AlphabetNumericAlphabetRegex = @"^[a-zA-Z][0-9][a-zA-Z]$";
        public const string NumericAlphabetNumericRegex = @"^[0-9][a-zA-Z][0-9]$";
        public const string DecimalTypeRegex = @"\d(\.\d{1,3})?";

        public const string EmptyStringORAlphaNumericRegEx = "^$|^[0-9a-zA-Z]+$";
        public const string EmptyStringORUnsignedByteRegEx = @"^$|^([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])$";
        public const string EmptyStringORNumericRegEx = @"^$|^(0|[1-9][0-9]*)$";
        public const string EmptyStringORAlphaNumericAllowSpaceRegEx = "^$|^[0-9a-zA-Z ][0-9a-zA-Z ]*$";
        public const string StartingWithAlbhabetRegEx = "^[a-zA-Z]{1}";
        public const string EmptyStringORStartingWithAlbhabetRegEx = "^$|^[a-zA-Z]{1}";
        public const string EmptyStringORAnyNumberRegEx = @"^$|^([0-9]*)$";
        public const string EmptyStringORJustSpacesRegex = "^$|^[ ]*$";
    }
}
