import Cocoa
import EventKit

// Set your variables here
let searchTitles = ["BACKUP", "PROJECT", "SUPPORT", "IH", "FR", "GLG", "MB", "FUND", "FINANCE", "RW", "OG","HGCC"]
let startDateString = "2018-10-01"
let endDateString = "2018-11-01"
let calendarsToSearch = ["Marie Work", "Elliott Caldwell"]

// this converts text-representation (string) to an actual date object
let formatter = DateFormatter()
formatter.dateFormat = "yyyy-MM-dd"

// guard ensures that these variables are objects (i.e. returning something that isn't empty/nil)
guard
    let startDate = formatter.date(from: startDateString),
    let endDate = formatter.date(from: endDateString)
    else {
        print("Cannot set dates to search")
        exit(EXIT_FAILURE)
}

let eventStore = EKEventStore()
eventStore.requestAccess(to: .event) { (allowed, error) in
    let calendars = eventStore.calendars(for: .event).filter({ (calendar) -> Bool in
        if (calendarsToSearch.contains(calendar.title)) {
            return true
        }
        return false
    })
    /*
    // this will get the wrong calendar at present, so need to figure out how to get the right one!
    guard let calendar = eventStore.defaultCalendarForNewEvents else {
        print("No default calendar")
        exit(EXIT_FAILURE)
    }
    */
    
    
    for calendar in calendars {
        print(calendar.title)
        print("Event titles matching \"\(searchTitles)\" between \(startDateString) -> \(endDateString)")
        print("–––––––––––––––––––––––––––––")
        
        // Creates predicate (search paramaters)
        let predicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: [calendar])
        // Get events based off search predicate
        let events = eventStore.events(matching: predicate)
        
        // Go through all of the search titles you defined
        for searchTitle in searchTitles {
            // We want to store the duration outside of looping through all of the events (otherwise it'll work out the duration of each event, rather than total duration of all events)
            var durationSum: Double = 0.0
            var i = 0
            // Go through each of the events to search for your search title
            for event in events {
                guard
                    let title = event.title,
                    let startDate = event.startDate,
                    let endDate = event.endDate
                    else {
                        continue
                }
                
                // If the title (case insensitive by lowercasing everything) matches your search title, we add the duration in seconds to the durationSum variable
                if (title.lowercased().contains(searchTitle.lowercased())) {
                    i = i + 1
                    let eventDuration = endDate.timeIntervalSince(startDate)
                    durationSum = durationSum + eventDuration
                }
            }
            
            // Convert final summed duration to hours
            let durationHoursSum = durationSum / 60 / 60
            
            // Print the search results
            print("\(searchTitle): \(i) events: \(durationHoursSum) hrs")
        }
        print("––––––––––––––––––––")
    }
}
