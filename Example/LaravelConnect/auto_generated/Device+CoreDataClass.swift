/*
 * Device
 *
 * Generated By LaravelConnect for iOS on 2017-12-03 00:14:46
 *
 */
 
import Foundation
import CoreData



@objc(Device)
public class Device: NSManagedObject {

    class var modelPath: String {       
        return "device"
    }
    
    class var primaryKey: String {       
        return "id"
    }

}


extension Device {

@NSManaged  public var id: Int64
@NSManaged  public var userId: Int64
@NSManaged  public var uuid: String
@NSManaged  public var platform: String
@NSManaged  public var pushId: String
@NSManaged  public var deletedAt: NSDate
@NSManaged  public var createdAt: NSDate
@NSManaged  public var updatedAt: NSDate
 

@NSManaged  public var user: User
 

 

    @nonobjc  public class func fetchRequest() -> NSFetchRequest<Device> {
        return NSFetchRequest<Device>(entityName: "Device")
    }

}