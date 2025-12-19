//
//  cucumber.m
//  workerUITests
//
//  Created by Majoros Máté on 2025. 12. 18..
//

#import <Foundation/Foundation.h>
//Replace CucumberishExampleUITests with the name of your swift test target
#import "workerUITests-Swift.h"

__attribute__((constructor))
void CucumberishInit()
{
    [CucumberishInitializer CucumberishSwiftInit];
}
