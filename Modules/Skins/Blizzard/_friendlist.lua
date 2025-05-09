local Module = VUI:NewModule("Skins.Friendlist");

function Module:OnEnable()
    if (VUI:Color()) then
        VUI:Skin(AddFriendEntryFrame, true)
        VUI:Skin(AddFriendFrame.Border, true)
        VUI:Skin(FriendsFrame, true)
        VUI:Skin(FriendsFrame.NineSlice, true)
        VUI:Skin(FriendsFrameInset, true)
        VUI:Skin(FriendsFrameInset.NineSlice, true)
        VUI:Skin(FriendsFriendsFrame, true)
        VUI:Skin(FriendsFriendsFrame.Border, true)
        VUI:Skin(RecruitAFriendFrame, true)
        VUI:Skin(RecruitAFriendFrame.RecruitList, true)
        VUI:Skin(RecruitAFriendFrame.RecruitList.Header, true)
        VUI:Skin(RecruitAFriendFrame.RecruitList.ScrollFrameInset, true)
        VUI:Skin(RecruitAFriendFrame.RecruitList.ScrollFrameInset.NineSlice, true)
        VUI:Skin(RecruitAFriendFrame.RewardClaiming, true)
        VUI:Skin(RecruitAFriendFrame.RewardClaiming.Inset, true)
        VUI:Skin(RecruitAFriendFrame.RewardClaiming.Inset.NineSlice, true)
        VUI:Skin(RecruitAFriendRecruitmentFrame, true)
        VUI:Skin(RecruitAFriendRecruitmentFrame.Border, true)
        VUI:Skin(WhoFrameListInset, true)
        VUI:Skin(WhoFrameListInset.NineSlice, true)
        VUI:Skin(WhoFrameEditBoxInset, true)
        VUI:Skin(WhoFrameEditBoxInset.NineSlice, true)
        VUI:Skin(FriendsFrameBattlenetFrame.BroadcastFrame, true)
        VUI:Skin(FriendsFrameBattlenetFrame.BroadcastFrame.Border, true)

        -- Tabs
        VUI:Skin(FriendsTabHeaderTab1, true)
        VUI:Skin(FriendsTabHeaderTab2, true)
        VUI:Skin(FriendsTabHeaderTab3, true)
        VUI:Skin(FriendsFrameTab1, true)
        VUI:Skin(FriendsFrameTab2, true)
        VUI:Skin(FriendsFrameTab3, true)
        VUI:Skin(FriendsFrameTab4, true)
    end
end
