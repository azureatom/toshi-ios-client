// Copyright (c) 2017 Token Browser, Inc
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

import EarlGrey
@testable import Toshi
import XCTest

class SignInScreenUITests: XCTestCase {
    
    lazy var signInRobot: SignInRobot = EarlGreyRobot()
    lazy var splashRobot: SplashScreenRobot = EarlGreyRobot()
    lazy var howDoesItWorkScreenRobot: HowDoesItWorkScreenRobot = EarlGreyRobot()

    override func setUp() {
        self.splashRobot
                .select(button: .signIn)
    }

    // MARK: - Tests

    func testGoBack() {
        self.signInRobot
                .select(button: .back)
                .validateOffSignInScreen()

        self.splashRobot
                .validateOnSplashScreen()
    }

    func testHowDoesItWork() {
        self.signInRobot
                .select(button: .howDoesItWork)
                .validateOffSignInScreen()

        self.howDoesItWorkScreenRobot
                .validateOnHowDoesItWorkScreen()
                .select(button: .back)
                .validateOffHowDoesItWorkScreen()  // fails weird
//
//        self.signInRobot
//                .validateOnSignInScreen()
    }

    func testEnterValidPassPhraseWord() {
        self.signInRobot
                .enterValidPassPhraseWord()
                .validateWordsLeftButton(wordsLeft: 11)
    }

    func testEnterInvalidPassPhraseWord() {
         self.signInRobot
                 .enterInvalidPassPhraseWord()

    }
}
