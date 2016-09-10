//
//  ComplicationController.swift
//  MyNextTrain WatchKit Extension
//
//  Created by FAHAD RIAZ on 8/13/16.
//  Copyright © 2016 FAHAD RIAZ. All rights reserved.
//

import ClockKit


class ComplicationController: NSObject, CLKComplicationDataSource {
	
	public func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void) {
		handler(nil)
	}

    
    public func getSupportedTimeTravelDirections(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimeTravelDirections) -> Void) {
        
    }

    private func getTimelineStartDate(for complication: CLKComplication, withHandler handler: (Date?) -> Void) {
        handler(nil)
    }
    
    private func getTimelineEndDate(for complication: CLKComplication, withHandler handler: (Date?) -> Void) {
        handler(nil)
    }
    
    private func getPrivacyBehavior(for complication: CLKComplication, withHandler handler: (CLKComplicationPrivacyBehavior) -> Void) {
        handler(.showOnLockScreen)
    }
    
    // MARK: - Timeline Population
    
    func getTimelineEntries(for complication: CLKComplication, before date: Date, limit: Int, withHandler handler: @escaping (([CLKComplicationTimelineEntry]?) -> Void)) {
        // Call the handler with the timeline entries prior to the given date
        handler(nil)
    }
    
    func getTimelineEntries(for complication: CLKComplication, after date: Date, limit: Int, withHandler handler: @escaping (([CLKComplicationTimelineEntry]?) -> Void)) {
        // Call the handler with the timeline entries after to the given date
        handler(nil)
    }
    
    // MARK: - Placeholder Templates
    
    private func getLocalizableSampleTemplate(for complication: CLKComplication, withHandler handler: (CLKComplicationTemplate?) -> Void) {
        // This method will be called once per supported complication, and the results will be cached
        handler(nil)
    }
        
}
