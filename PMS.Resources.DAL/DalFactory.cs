using PmsEntity = PMS.Resources.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using PMS.Resources.Common.Converter;
using System.Data.SqlClient;
using System.Data;

namespace PMS.Resources.DAL
{
    public class DalFactory : IDalFactory
    {
        public void LogExceptionToDb(PmsEntity.ExceptionLog additionalExData)
        {
            throw new NotImplementedException();
        }
        public bool AddBooking(int propertyId, string bookingXml)
        {
            var isAdded = false;
            using (var pmsContext = new PmsEntities())
            {
                var propId = new SqlParameter
                {
                    ParameterName = "propertyID",
                    DbType = DbType.Int32,
                    Value = propertyId
                };

                var roomBookingXml = new SqlParameter
                {
                    ParameterName = "bookingXML",
                    DbType = DbType.Xml,
                    Value = bookingXml
                };

                var result = pmsContext.Database.ExecuteSqlCommand("InsertBooking @propertyID, @bookingXML", propId, roomBookingXml);
                isAdded = true;
            }
            return isAdded;
        }
        public List<PmsEntity.Booking> GetBooking(int propertyId, DateTime startDate, DateTime endDate)
        {
            var bookings = new List<PmsEntity.Booking>();

            using (var pmsContext = new PmsEntities())
            {
                var resultSet = pmsContext.GETALLBOOKINGS(propertyId, startDate, endDate);
                if (resultSet == null) return bookings;
                foreach (var result in resultSet)
                {
                    var booking = new PmsEntity.Booking();
                    booking.Id = result.ID;
                    booking.CheckinTime = result.CHECKINTIME ;
                    booking.CheckoutTime = result.CHECKOUTTIME;

                    booking.RoomBookings = new List<PmsEntity.RoomBooking>
                    {
                        new PmsEntity.RoomBooking
                        { 
                            Id = result.ROOMBOOKINGID,
                            Room = new PmsEntity.Room
                            {
                                Id = result.ROOMID,
                                Number = result.ROOMNUMBER
                            },
                            Guest = new PmsEntity.Guest
                            {
                                Id = result.GUESTID,
                                FirstName = result.FIRSTNAME,
                                LastName = result.LASTNAME
                            }                            
                        }
                    };
                    bookings.Add(booking);
                }
            }
            return bookings;
        }
        public bool AddProperty(PmsEntity.Property property)
        {
            var isAdded = false;
            return isAdded;
        }
        public bool UpdateProperty(PmsEntity.Property property)
        {
            var isUpdated = false;
            return isUpdated;
        }
        public bool DeleteProperty(int propertyId)
        {
            var isDeleted = false;
            return isDeleted;
        }
        public List<PmsEntity.Property> GetAllProperty()
        {
            var properties = new List<PmsEntity.Property>();
            return properties;
        }
        public bool AddPropertyType(PmsEntity.PropertyType propertyType)
        {
            var isAdded = false;
            return isAdded;
        }
        public bool UpdatePropertyType(PmsEntity.PropertyType propertyType)
        {
            var isUpdated = false;
            return isUpdated;
        }
        public bool DeletePropertyType(int propertyTypeId)
        {
            var isDeleted = false;
            return isDeleted;
        }
        public List<PmsEntity.PropertyType> GetAllPropertyType()
        {
            var propertyTypes = new List<PmsEntity.PropertyType>();
            return propertyTypes;
        }
        public bool AddRoom(PmsEntity.Room room)
        {
            var isAdded = false;
            return isAdded;
        }
        public bool UpdateRoom(PmsEntity.Room room)
        {
            var isUpdated = false;
            return isUpdated;
        }
        public bool DeleteRoom(int roomId)
        {
            var isDeleted = false;
            return isDeleted;
        }
        public List<PmsEntity.Room> GetRoomByProperty(int propertyId)
        {
            var rooms = new List<PmsEntity.Room>();
            using (var pmsContext = new PmsEntities())
            {
                rooms = pmsContext.Rooms.Where(x => x.IsActive && x.PropertyID == propertyId)
                                                 .Select(x => new PmsEntity.Room
                                                 {
                                                     CreatedOn = x.CreatedOn,
                                                     Number = x.Number,
                                                     CreatedBy = x.CreatedBy,
                                                     LastUpdatedBy = x.LastUpdatedBy,
                                                     LastUpdatedOn = x.LastUpdatedOn,
                                                     Id = x.ID,
                                                     Property = new PmsEntity.Property
                                                     {
                                                         Id = x.PropertyID
                                                     },
                                                     IsActive = x.IsActive,
                                                     RoomType = new PmsEntity.RoomType
                                                     {
                                                         Id = x.RoomTypeID
                                                     }
                                                 }).ToList();

            }
            return rooms;
        }
        public bool AddRateType(PmsEntity.RateType rateType)
        {
            var isAdded = false;
            return isAdded;
        }
        public bool UpdateRateType(PmsEntity.RateType rateType)
        {
            var isUpdated = false;
            return isUpdated;
        }
        public bool DeleteRateType(int rateTypeId)
        {
            var isDeleted = false;
            return isDeleted;
        }
        public List<PmsEntity.RateType> GetRateTypeByProperty(int propertyId)
        {
            var rateTypes = new List<PmsEntity.RateType>();
            using (var pmsContext = new PmsEntities())
            {
                rateTypes = pmsContext.RateTypes.Where(x => x.IsActive && x.PropertyID == propertyId)
                                                 .Select(x => new PmsEntity.RateType
                                                 {
                                                     CreatedOn = x.CreatedOn,
                                                     Name = x.NAME,
                                                     CreatedBy = x.CreatedBy,
                                                     LastUpdatedBy = x.LastUpdatedBy,
                                                     LastUpdatedOn = x.LastUpdatedOn,
                                                     Id = x.ID,
                                                     PropertyId = x.PropertyID
                                                 }).ToList();

            }
            return rateTypes;
        }
        public bool AddRoomType(PmsEntity.RoomType roomType)
        {
            var isAdded = false;
            return isAdded;
        }
        public bool UpdateRoomType(PmsEntity.RoomType roomType)
        {
            var isUpdated = false;
            return isUpdated;
        }
        public bool DeleteRoomType(int roomTypeId)
        {
            var isDeleted = false;
            return isDeleted;
        }
        public List<PmsEntity.RoomType> GetRoomTypeByProperty(int propertyId)
        {
            var roomTypes = new List<PmsEntity.RoomType>();
            using (var pmsContext = new PmsEntities())
            {
                roomTypes = pmsContext.RoomTypes.Where(x => x.IsActive && x.PropertyID == propertyId)
                                                 .Select(x => new PmsEntity.RoomType
                                                 {
                                                     CreatedOn = x.CreatedOn,
                                                     Name = x.NAME,
                                                     CreatedBy = x.CreatedBy,
                                                     LastUpdatedBy = x.LastUpdatedBy,
                                                     LastUpdatedOn = x.LastUpdatedOn,
                                                     Id = x.ID,
                                                     PropertyId = x.PropertyID
                                                 }).ToList();
               
            }

            return roomTypes;
        }
        public bool AddRoomPrice(PmsEntity.RoomPricing roomPrice)
        {
            var isAdded = false;
            return isAdded;
        }
        public bool UpdateRoomPrice(PmsEntity.RoomPricing roomPrice)
        {
            var isUpdated = false;
            return isUpdated;
        }
        public bool DeleteRoomPrice(int priceId)
        {
            var isDeleted = false;
            return isDeleted;
        }
        public List<PmsEntity.RoomPricing> GetRoomPriceByProperty(int propertyId)
        {
            var roomPricing = new List<PmsEntity.RoomPricing>();
            return roomPricing;
        }
        public bool AddRoomStatus(PmsEntity.RoomStatus roomStatus)
        {
            var isAdded = false;
            return isAdded;
        }
        public bool UpdateRoomStatus(PmsEntity.RoomStatus roomStatus)
        {
            var isUpdated = false;
            return isUpdated;
        }
        public bool DeleteRoomStatus(int statusId)
        {
            var isDeleted = false;
            return isDeleted;
        }
        public List<PmsEntity.RoomStatus> GetRoomStatus()
        {
            var roomStatus = new List<PmsEntity.RoomStatus>();
            return roomStatus;
        }
        public bool AddReward(PmsEntity.GuestReward reward)
        {
            var isAdded = false;
            return isAdded;
        }
        public bool UpdateReward(PmsEntity.GuestReward reward)
        {
            var isUpdated = false;
            return isUpdated;
        }
        public bool DeleteReward(int rewardId)
        {
            var isDeleted = false;
            return isDeleted;
        }
        public List<PmsEntity.GuestReward> GetAllReward()
        {
            var rewards = new List<PmsEntity.GuestReward>();
            return rewards;
        }
        public List<PmsEntity.GuestReward> GetRewardByGuestId(int guestId)
        {
            var rewards = new List<PmsEntity.GuestReward>();
            return rewards;
        }
        public bool AddRewardCategory(PmsEntity.RewardCategory rewardCategory)
        {
            var isAdded = false;
            return isAdded;
        }
        public bool UpdateRewardCategory(PmsEntity.RewardCategory rewardCategory)
        {
            var isUpdated = false;
            return isUpdated;
        }
        public bool DeleteRewardCategory(int catId)
        {
            var isDeleted = false;
            return isDeleted;
        }
        public List<PmsEntity.RewardCategory> GetAllRewardCategory()
        {
            var rewardCategory = new List<PmsEntity.RewardCategory>();
            return rewardCategory;
        }
        public List<PmsEntity.Room> GetRoomByDate(int propertyId, DateTime checkinDate, DateTime checkoutDate)
        {
            var rooms = new List<PmsEntity.Room>();
            using (var pmsContext = new PmsEntities())
            {
                var resultSet = pmsContext.GETROOMSTATUS(propertyId, checkinDate, checkoutDate);
                if (resultSet == null) return rooms;
                foreach(var result in resultSet)
                {
                    var room = new PmsEntity.Room();
                    room.RoomType = new PmsEntity.RoomType();
                    room.RoomStatus = new PmsEntity.RoomStatus();
                    room.Id = result.ID;
                    room.Number = result.NUMBER;
                    room.RoomType.Id = result.ROOMTypeID;
                    room.RoomStatus.Name = result.ROOMSTATUS;
                 
                    rooms.Add(room);
                }
            }
            return rooms;
        }
        public List<PmsEntity.Booking> GetGuestHistory(int guestId)
        {
            var bookings = new List<PmsEntity.Booking>();

            using (var pmsContext = new PmsEntities())
            {
                var resultSet = pmsContext.GETGUESTTRANSACTIONS(guestId);
                if (resultSet == null) return bookings;
                foreach (var result in resultSet)
                {
                    var booking = new PmsEntity.Booking();
                    booking.CheckinTime = result.CheckinTime;
                    booking.CheckoutTime = result.CheckoutTime;
                    TimeSpan? ts = booking.CheckoutTime - booking.CheckinTime;
                    booking.DurationOfStay = ts.HasValue ? ts.Value.TotalHours : 0;
                    booking.RoomBookings = new List<PmsEntity.RoomBooking>
                    {
                        new PmsEntity.RoomBooking
                        { 
                            Room = new PmsEntity.Room
                            {
                                Number = result.ROOMNUMBER,
                                RoomType = new PmsEntity.RoomType
                                {
                                    Name = result.ROOMTYPE
                                },
                                Property = new PmsEntity.Property
                                {
                                   PropertyDetails = result.PROPERTY
                                }
                            }
                        }
                    };
                    bookings.Add(booking);
                }
            }
            return bookings;
        }
        public bool UpdateBooking(PmsEntity.Booking booking)
        {
            var isUpdated = false;
            using (var pmsContext = new PmsEntities())
            {
                var bookingId = new SqlParameter
                {
                    ParameterName = "BOOKINGID",
                    DbType = DbType.Int32,
                    Value = booking.Id
                };

                var dtCheckin = new SqlParameter
                {
                    ParameterName = "CHECKINTIME",
                    DbType = DbType.DateTime,
                    Value = booking.CheckinTime
                };

                var dtCheckout = new SqlParameter
                {
                    ParameterName = "CHECKOUTTIME",
                    DbType = DbType.DateTime,
                    Value = booking.CheckoutTime
                };

                var roomId = new SqlParameter
                {
                    ParameterName = "RoomID",
                    DbType = DbType.Int32,
                    Value = booking.RoomBookings[0].RoomId
                };

                var result = pmsContext.Database.ExecuteSqlCommand("UpdateBooking @BOOKINGID, @CHECKINTIME, @CHECKOUTTIME, @RoomID", bookingId, dtCheckin, dtCheckout, roomId);
                isUpdated = true;
            }
            return isUpdated;
        }

        public List<PmsEntity.State> GetStateByCountry(int id)
        {
            var states = new List<PmsEntity.State>();

            using (var pmsContext = new PmsEntities())
            {
                states = pmsContext.States.Where(x => x.IsActive && x.CountryID == id)
                           .Select(x => new PmsEntity.State
                           {
                               ID = x.ID,
                               Name = x.Name,
                               CountryId = x.CountryID.Value
                           }).ToList();
                    
            }

            return states;
        }

        public List<PmsEntity.City> GetCityByState(int id)
        {
            var city = new List<PmsEntity.City>();
            using (var pmsContext = new PmsEntities())
            {
                city = pmsContext.Cities.Where(x => x.IsActive && x.StateID == id)
                           .Select(x => new PmsEntity.City
                           {
                               Id = x.ID,
                               Name = x.Name,
                               StateId = x.StateID,
                               CountryId = x.CountryID
                           }).ToList();

            }
            return city;
        }

        public List<PmsEntity.Country> GetCountry()
        {
            var country = new List<PmsEntity.Country>();
            using (var pmsContext = new PmsEntities())
            {
                country = pmsContext.Countries.Where(x => x.IsActive)
                           .Select(x => new PmsEntity.Country
                           {
                               Id = x.ID,
                               Name = x.Name
                           }).ToList();

            }
            return country;
        }
        public List<PmsEntity.Guest> GetAllGuest()
        {
            var guest = new List<PmsEntity.Guest>();
            using (var pmsContext = new PmsEntities())
            {
                guest = (from x in pmsContext.Guests
                         where x.IsActive
                         select new PmsEntity.Guest
                         {
                             Id = x.ID,
                             DOB = x.DOB,
                             EmailAddress = x.EmailAddress,
                             FirstName = x.FirstName,
                             Gender = x.Gender,
                             LastName = x.LastName,
                             MobileNumber = x.MobileNumber,
                             PhotoPath = x.PhotoPath,
                             GuestMappings = (from m in pmsContext.GuestMappings                                              
                                              join i in pmsContext.IDTypes on m.IDTYPEID equals i.ID
                                              where m.IsActive && m.GUESTID == x.ID
                                              select new PmsEntity.GuestMapping
                                              {
                                                Id = m.ID,
                                                IDDETAILS = m.IDDETAILS,
                                                IdType = new PmsEntity.IDType
                                                {
                                                    ID = i.ID,
                                                    Name = i.Name
                                                }
                                              }).ToList()                                          

                         }).ToList();
            }
            return guest;
        }

        public List<PmsEntity.Tax> GetPaymentCharges(int? propertyId, int? roomTypeId, int? rateTypeId, int? noOfHours, bool? IsHourly)
        {
            var taxes = new List<PmsEntity.Tax>();
            using (var pmsContext = new PmsEntities())
            {
                var resultSet = pmsContext.GETBOOKINGAMOUNT(propertyId, roomTypeId, rateTypeId, noOfHours, 0, IsHourly);
                if (resultSet == null) return taxes;
                foreach (var result in resultSet.OrderBy(x => x.OrderBy))
                {
                    var tax = new PmsEntity.Tax();
                    tax.TaxName = result.ITEM;
                    tax.Value = result.ITEMAMOUNT;
                    tax.IsDefaultCharges = true;

                    taxes.Add(tax);
                }
            }
            return taxes;
        }

        public bool AddInvoice(int propertyId, string invoiceXml)
        {
            var isAdded = false;
            using (var pmsContext = new PmsEntities())
            {
                var propId = new SqlParameter
                {
                    ParameterName = "propertyID",
                    DbType = DbType.Int32,
                    Value = propertyId
                };

                var invoicexml = new SqlParameter
                {
                    ParameterName = "InvoiceXML",
                    DbType = DbType.Xml,
                    Value = invoiceXml
                };

                var result = pmsContext.Database.ExecuteSqlCommand("InsertInvoice @propertyID, @InvoiceXML", propId, invoicexml);
                isAdded = true;
            }
            return isAdded;
        }

        public PmsEntity.Invoice GetInvoiceById(int invoiceId)
        {
            var invoice = new PmsEntity.Invoice();
            var taxes = new List<PmsEntity.Tax>();
            var paymentDetails = new List<PmsEntity.InvoicePaymentDetail>();
            using (var pmsContext = new PmsEntities())
            {
                var resultSet = pmsContext.GETINVOICEDETAILS(invoiceId).ToList();
                if (resultSet == null) return invoice;                

                var distinctBaseRoomCharge = resultSet.AsEnumerable()
                       .Select(row => new
                       {
                           ItemName = row.ItemName,
                           ItemValue = row.ItemValue
                       })
                       .Where(x => x.ItemName.Equals("ROOM CHARGES"))
                       .Distinct().ToList();

                if (distinctBaseRoomCharge != null && distinctBaseRoomCharge.Count > 0)
                {
                    foreach (var basecharge in distinctBaseRoomCharge)
                    {
                        taxes.Add(new PmsEntity.Tax { TaxName = basecharge.ItemName, Value = basecharge.ItemValue, IsDefaultCharges = true });
                    }
                }

                var distinctTaxValues = resultSet.AsEnumerable()
                        .Select(row => new
                        {
                            TaxName = row.TaxShortName,
                            TaxValue = row.TaxAmount
                        })
                        .Distinct().ToList();

                if (distinctTaxValues != null && distinctTaxValues.Count > 0)
                {
                    foreach (var tax in distinctTaxValues)
                    {
                        taxes.Add(new PmsEntity.Tax { TaxName = tax.TaxName, Value = tax.TaxValue, IsDefaultCharges = true });
                    }
                }               

                // default charges
                var distinctTotalRoomCharge = resultSet.AsEnumerable()
                       .Select(row => new
                       {
                           ItemName = row.ItemName,
                           ItemValue = row.ItemValue
                       })
                       .Where(x => x.ItemName.Equals("Total Room Charge"))
                       .Distinct().ToList();

                if (distinctTotalRoomCharge != null && distinctTotalRoomCharge.Count > 0)
                {
                    foreach (var totalcharge in distinctTotalRoomCharge)
                    {
                        taxes.Add(new PmsEntity.Tax { TaxName = totalcharge.ItemName, Value = totalcharge.ItemValue, IsDefaultCharges = true });
                    }
                }

                var distinctItemValues = resultSet.AsEnumerable()
                        .Select(row => new
                        {
                            ItemName = row.ItemName,
                            ItemValue = row.ItemValue
                        })
                        .Where(x => !x.ItemName.Equals("ROOM CHARGES") && !x.ItemName.Equals("Total Room Charge"))
                        .Distinct().ToList();

                if (distinctItemValues != null && distinctItemValues.Count > 0)
                {
                    foreach (var tax in distinctItemValues)
                    {
                        // user defined charges
                        taxes.Add(new PmsEntity.Tax { TaxName = tax.ItemName, Value = tax.ItemValue, IsDefaultCharges = false });
                    }
                }

                var distinctPaymentValues = resultSet.AsEnumerable()
                        .Select(row => new
                        {
                            Detail = row.PaymentDetails,
                            Mode = row.PaymentMode,
                            Value = row.PaymentValue
                        })
                        .Distinct().ToList();

                if (distinctPaymentValues != null && distinctPaymentValues.Count > 0)
                {
                    foreach (var payment in distinctPaymentValues)
                    {
                        paymentDetails.Add(new PmsEntity.InvoicePaymentDetail { PaymentDetails = payment.Detail, PaymentValue = payment.Value, PaymentMode = payment.Mode});
                    }
                }

                var distinctOtherCharges = resultSet.AsEnumerable()
                        .Select(row => new
                        {
                            Discount = row.DISCOUNT,
                            TotalAmt = row.TotalAmount,
                            BookingId = row.BookingID,
                            InvoiceId = row.InvoiceId,
                        })
                        .Distinct().ToList();

                if (distinctOtherCharges != null && distinctOtherCharges.Count > 0)
                {
                    foreach (var otherCharges in distinctOtherCharges)
                    {
                        invoice.Discount = otherCharges.Discount;
                        invoice.TotalAmount = otherCharges.TotalAmt;
                        invoice.BookingId = otherCharges.BookingId;
                        invoice.Id = otherCharges.InvoiceId;
                    }
                }
            }

            invoice.Tax = taxes;
            invoice.InvoicePaymentDetails = paymentDetails;
            return invoice;
        }

        public PmsEntity.Booking GetBookingById(int bookingId)
        {
            var booking = new PmsEntity.Booking();
            var roomBookings = new List<PmsEntity.RoomBooking>();
            var guests = new List<PmsEntity.Guest>();
            var addresses = new List<PmsEntity.Address>();
            var guestMappings = new List<PmsEntity.GuestMapping>();
            var additionalGuests = new List<PmsEntity.AdditionalGuest>();

            using (var pmsContext = new PmsEntities())
            {
                var resultSet = pmsContext.GetBokingDetails(bookingId).ToList();
                if (resultSet == null) return booking;

                //Populate Booking Object

                var bookingInformation = resultSet.First();
                if (bookingInformation != null)
                {
                    booking.Id = bookingInformation.ID;
                    booking.CheckinTime = bookingInformation.CheckinTime;
                    booking.CheckoutTime = bookingInformation.CheckoutTime;
                    booking.NoOfAdult = bookingInformation.NoOfAdult;
                    booking.NoOfChild = bookingInformation.NoOfChild;
                    booking.GuestRemarks = bookingInformation.GuestRemarks;
                    booking.TransactionRemarks = bookingInformation.TransactionRemarks;
                    booking.IsActive = bookingInformation.IsActive;
                    booking.ISHOURLYCHECKIN = bookingInformation.ISHOURLYCHECKIN;
                    booking.HOURSTOSTAY = bookingInformation.HOURSTOSTAY;
                    booking.CreatedBy = bookingInformation.CreatedBy;
                    booking.CreatedOn = bookingInformation.CreatedOn;
                    booking.LastUpdatedBy = bookingInformation.LastUpdatedBy;
                    booking.LastUpdatedOn = bookingInformation.LastUpdatedOn;
                    booking.Status = bookingInformation.Status;
                }
                else
                {
                    return null;
                }


                //Populate RoomBooking
                var distinctRoomBookings = resultSet.AsEnumerable()
                        .Select(row => new
                        {
                            RoomID = row.RoomID.Value,
                            ID = row.RoomBookingID,
                            GuestID = row.RoomBookingGuestID
                        })
                        .Distinct().ToList();

                if (distinctRoomBookings != null && distinctRoomBookings.Count > 0)
                {
                    foreach (var roomBooking in distinctRoomBookings)
                    {
                        booking.RoomBookings.Add(new PmsEntity.RoomBooking { RoomId = roomBooking.RoomID, Id = roomBooking.ID, GuestID = roomBooking.GuestID });
                    }
                }


                //Populate Additional Guests
                var distinctAdditionalGuests = resultSet.AsEnumerable()
                    .Select(row => new
                    {
                        FirstName = row.AdditionalGuestFirstName,
                        LastName = row.AdditionalGuestLastName,
                        GUESTIDPath = row.AdditionalGuestIDPath,
                        Gender = row.AdditionalGuestGender,
                        Id = row.AdditionalGuestID
                    })
                    .Distinct().ToList();

                if (distinctAdditionalGuests != null && distinctAdditionalGuests.Count > 0)
                {
                    foreach (var additionalGuest in distinctAdditionalGuests)
                    {
                        booking.AdditionalGuests.Add(new PmsEntity.AdditionalGuest { FirstName = additionalGuest.FirstName, LastName = additionalGuest.LastName, Gender = additionalGuest.Gender, GUESTIDPath = additionalGuest.GUESTIDPath, Id = additionalGuest.Id, BookingId = booking.Id });
                    }
                }


                //Populate GuestsMapping
                var distinctGuestsMapping = resultSet.AsEnumerable()
                    .Select(row => new
                    {
                        IDTYPEID = row.IDTYPEID,
                        GUESTID = row.GuestMappingGuestID,
                        IDDETAILS = row.GuestMappingIDDETAILS,
                        IdExpiryDate = row.IDExpiryDate,
                        IdIssueState = row.IDIssueState,
                        IdIssueCountry = row.IdIssueCountry,
                        Id = row.GuestMappingId
                    }).Distinct().ToList();

                if (distinctGuestsMapping != null && distinctGuestsMapping.Count > 0)
                {
                    foreach (var guestMapping in distinctGuestsMapping)
                    {
                        booking.GuestMappings.Add(new PmsEntity.GuestMapping { Id = guestMapping.Id, IDTYPEID = guestMapping.IDTYPEID, GUESTID = guestMapping.GUESTID, IDDETAILS = guestMapping.IDDETAILS, IdExpiryDate = guestMapping.IdExpiryDate, IdIssueState = guestMapping.IdIssueState, IdIssueCountry = guestMapping.IdIssueCountry });
                    }
                }


                //Populate Guests
                var distinctGuests = resultSet.AsEnumerable()
                    .Select(row => new
                    {
                        GuestID = row.GuestID,
                        FirstName = row.FirstName,
                        LastName = row.LastName,
                        MobileNumber = row.MobileNumber,
                        EmailAddress = row.EmailAddress,
                        DOB = row.DOB,
                        PhotoPath = row.PhotoPath,
                        Gender = row.Gender
                    }).Distinct().ToList();

                if (distinctGuests != null && distinctGuests.Count > 0)
                {
                    foreach (var guest in distinctGuests)
                    {
                        booking.Guests.Add(new PmsEntity.Guest { Id = guest.GuestID, FirstName = guest.FirstName, LastName = guest.LastName, MobileNumber = guest.MobileNumber, EmailAddress = guest.EmailAddress, DOB = guest.DOB, PhotoPath = guest.PhotoPath, Gender = guest.Gender });
                    }
                }

                return booking;
            }
        }
    }
}
