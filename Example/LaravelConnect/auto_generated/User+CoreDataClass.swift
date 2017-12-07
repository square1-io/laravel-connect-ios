/*
 * User
 *
 * Generated By LaravelConnect for iOS on 2017-12-03 00:14:46
 *
 */
 
import Foundation
import CoreData



@objc(User)
public class User: NSManagedObject {

    class var modelPath: String {       
        return "user"
    }
    
    class var primaryKey: String {       
        return "id"
    }

}


extension User {

@NSManaged  public var id: Int64
@NSManaged  public var username: String
@NSManaged  public var forename: String
@NSManaged  public var surname: String
@NSManaged  public var email: String
@NSManaged  public var phone: String
@NSManaged  public var biography: String
@NSManaged  public var imageUrl: String
@NSManaged  public var emailVerified: Bool
@NSManaged  public var deletedAt: NSDate
@NSManaged  public var createdAt: NSDate
@NSManaged  public var updatedAt: NSDate
 

@NSManaged  public var professional: Professional
@NSManaged  public var jobs: NSSet
@NSManaged  public var reviews: NSSet
@NSManaged  public var messages: NSSet
@NSManaged  public var payments: NSSet
@NSManaged  public var devices: NSSet
 

// MARK: Generated accessors for jobs
@objc(addJobsObject:)
@NSManaged  public func addToJobs(_ value: Job)

@objc(removeJobsObject:)
 @NSManaged  public func removeFromJobs(_ value: Job)

@objc(addJobs:)
@NSManaged  public func addToJobs(_ values: NSSet)

@objc(removeJobs:)
@NSManaged  public func removeFromJobs(_ values: NSSet)

 // MARK: Generated accessors for reviews
@objc(addReviewsObject:)
@NSManaged  public func addToReviews(_ value: ProfessionalReview)

@objc(removeReviewsObject:)
 @NSManaged  public func removeFromReviews(_ value: ProfessionalReview)

@objc(addReviews:)
@NSManaged  public func addToReviews(_ values: NSSet)

@objc(removeReviews:)
@NSManaged  public func removeFromReviews(_ values: NSSet)

 // MARK: Generated accessors for messages
@objc(addMessagesObject:)
@NSManaged  public func addToMessages(_ value: JobQuotationMessage)

@objc(removeMessagesObject:)
 @NSManaged  public func removeFromMessages(_ value: JobQuotationMessage)

@objc(addMessages:)
@NSManaged  public func addToMessages(_ values: NSSet)

@objc(removeMessages:)
@NSManaged  public func removeFromMessages(_ values: NSSet)

 // MARK: Generated accessors for payments
@objc(addPaymentsObject:)
@NSManaged  public func addToPayments(_ value: JobPayment)

@objc(removePaymentsObject:)
 @NSManaged  public func removeFromPayments(_ value: JobPayment)

@objc(addPayments:)
@NSManaged  public func addToPayments(_ values: NSSet)

@objc(removePayments:)
@NSManaged  public func removeFromPayments(_ values: NSSet)

 // MARK: Generated accessors for devices
@objc(addDevicesObject:)
@NSManaged  public func addToDevices(_ value: Device)

@objc(removeDevicesObject:)
 @NSManaged  public func removeFromDevices(_ value: Device)

@objc(addDevices:)
@NSManaged  public func addToDevices(_ values: NSSet)

@objc(removeDevices:)
@NSManaged  public func removeFromDevices(_ values: NSSet)

  

    @nonobjc  public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User")
    }

}
