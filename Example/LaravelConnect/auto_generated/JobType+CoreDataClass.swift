/*
 * JobType
 *
 * Generated By LaravelConnect for iOS on 2017-12-03 00:14:46
 *
 */
 
import Foundation
import CoreData



@objc(JobType)
public class JobType: NSManagedObject {

    class var modelPath: String {       
        return "job_type"
    }
    
    class var primaryKey: String {       
        return "id"
    }

}


extension JobType {

@NSManaged  public var id: Int64
@NSManaged  public var name: String
@NSManaged  public var jobTypeDescription: String
@NSManaged  public var imageSrc: String
@NSManaged  public var bannerSrc: String
@NSManaged  public var parentId: Int64
@NSManaged  public var deletedAt: NSDate
@NSManaged  public var createdAt: NSDate
@NSManaged  public var updatedAt: NSDate
 

@NSManaged  public var children: NSSet
@NSManaged  public var parent: JobType
@NSManaged  public var jobs: NSSet
@NSManaged  public var keywords: NSSet
 

// MARK: Generated accessors for children
@objc(addChildrenObject:)
@NSManaged  public func addToChildren(_ value: JobType)

@objc(removeChildrenObject:)
 @NSManaged  public func removeFromChildren(_ value: JobType)

@objc(addChildren:)
@NSManaged  public func addToChildren(_ values: NSSet)

@objc(removeChildren:)
@NSManaged  public func removeFromChildren(_ values: NSSet)

 // MARK: Generated accessors for jobs
@objc(addJobsObject:)
@NSManaged  public func addToJobs(_ value: Job)

@objc(removeJobsObject:)
 @NSManaged  public func removeFromJobs(_ value: Job)

@objc(addJobs:)
@NSManaged  public func addToJobs(_ values: NSSet)

@objc(removeJobs:)
@NSManaged  public func removeFromJobs(_ values: NSSet)

 // MARK: Generated accessors for keywords
@objc(addKeywordsObject:)
@NSManaged  public func addToKeywords(_ value: Keyword)

@objc(removeKeywordsObject:)
 @NSManaged  public func removeFromKeywords(_ value: Keyword)

@objc(addKeywords:)
@NSManaged  public func addToKeywords(_ values: NSSet)

@objc(removeKeywords:)
@NSManaged  public func removeFromKeywords(_ values: NSSet)

  

    @nonobjc  public class func fetchRequest() -> NSFetchRequest<JobType> {
        return NSFetchRequest<JobType>(entityName: "JobType")
    }

}
