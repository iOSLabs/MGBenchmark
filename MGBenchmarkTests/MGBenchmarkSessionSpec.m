/*
 * Copyright (c) 2013 Mattes Groeger
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#import "MGBenchmarkTarget.h"
#import "MGBenchmarkSession.h"
#import "Kiwi.h"

SPEC_BEGIN(MGBenchmarkSessionSpec)

describe(@"MGBenchmarkSession", ^
{
	__block id output;
	__block MGBenchmarkSession *benchmark;

	it(@"should create instance", ^
	{
		output = [KWMock mockForProtocol:@protocol(MGBenchmarkTarget)];

		benchmark = [[MGBenchmarkSession alloc] initWithName:nil andTarget:output];

		[[theValue(benchmark.stepCount) should] equal:theValue(0)];
		[[theValue(benchmark.averageTime) should] equal:theValue(0)];
	});

	context(@"with fresh setup", ^
	{
		beforeEach(^
		{
			output = [KWMock mockForProtocol:@protocol(MGBenchmarkTarget)];
			
			benchmark = [[MGBenchmarkSession alloc] initWithName:nil andTarget:output];
		});

		it(@"should measure total execution time", ^
		{
			[[output shouldEventuallyBeforeTimingOutAfter(1)] receive:@selector(totalTime:inSession:)];

			sleep(1);

			[[theValue([benchmark total]) should] beGreaterThanOrEqualTo:theValue(1)];
			[[theValue(benchmark.stepCount) should] equal:theValue(0)];
			[[theValue(benchmark.averageTime) should] equal:theValue(0)];
		});

		it(@"should measure steps and total execution time", ^
		{
			[[output shouldEventuallyBeforeTimingOutAfter(2)] receive:@selector(totalTime:inSession:) withCount:2];
			[[output shouldEventuallyBeforeTimingOutAfter(2)] receive:@selector(passedTime:forStep:inSession:) withCount:2];

			sleep(1);

			[[theValue([benchmark step:@"foo"]) should] beGreaterThanOrEqualTo:theValue(1)];
			[[theValue([benchmark total]) should] beGreaterThanOrEqualTo:theValue(1)];
			[[theValue(benchmark.stepCount) should] equal:theValue(1)];
			[[theValue(benchmark.averageTime) should] beBetween:theValue(1) and:theValue(1.1)];

			sleep(1);

			[[theValue([benchmark step:nil]) should] beGreaterThanOrEqualTo:theValue(1)];
			[[theValue([benchmark total]) should] beGreaterThanOrEqualTo:theValue(2)];
			[[theValue(benchmark.stepCount) should] equal:theValue(2)];
			[[theValue(benchmark.averageTime) should] beBetween:theValue(1) and:theValue(1.2)];
		});
	});
});

SPEC_END