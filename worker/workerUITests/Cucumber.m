//
//  Cucumber.m
//  worker
//
//  Created by Majoros Máté on 2026. 01. 05..
//

// The Swift class and method need to be marked with @objc public to be visible in Objective-C
#import "workerUITests-Swift.h"

__attribute__((constructor))
void CucumberishInit()
{
    [CucumberishInitializer CucumberishSwiftInit];
}

