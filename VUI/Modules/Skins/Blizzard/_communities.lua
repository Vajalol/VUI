local Module = VUI:NewModule("Skins.Communities");

function Module:OnEnable()
    if (VUI:Color()) then
        VUI:Skin(CommunitiesFrame, true)
        VUI:Skin(CommunitiesFrame.GuildMemberDetailFrame, true)
        VUI:Skin(CommunitiesFrame.GuildMemberDetailFrame.Border, true)
        VUI:Skin(CommunitiesFrame.ChatEditBox, true)
        VUI:Skin(CommunitiesFrame.Chat.InsetFrame, true)
        VUI:Skin(CommunitiesFrame.Chat.InsetFrame.NineSlice, true)
        VUI:Skin(CommunitiesFrame.MemberList.InsetFrame, true)
        VUI:Skin(CommunitiesFrame.MemberList.InsetFrame.NineSlice, true)
        VUI:Skin(CommunitiesFrame.NineSlice, true)
        VUI:Skin(CommunitiesFrame.MemberList.ColumnDisplay, true)
        VUI:Skin(CommunitiesFrameInset, true)
        VUI:Skin(CommunitiesFrameInset.NineSlice, true)
        VUI:Skin(CommunitiesFrameCommunitiesList, true)
        VUI:Skin(CommunitiesFrameCommunitiesList.InsetFrame, true)
        VUI:Skin(CommunitiesFrameCommunitiesList.InsetFrame.NineSlice, true)
        VUI:Skin(CommunitiesFrameGuildDetailsFrame, true)
        VUI:Skin(CommunitiesFrame.GuildBenefitsFrame, true)
        VUI:Skin(ClubFinderGuildFinderFrame.InsetFrame, true)
        VUI:Skin(ClubFinderGuildFinderFrame.InsetFrame.NineSlice, true)
        VUI:Skin(ClubFinderCommunityAndGuildFinderFrame.InsetFrame, true)
        VUI:Skin(ClubFinderCommunityAndGuildFinderFrame.InsetFrame.NineSlice, true)
        VUI:Skin({
            CommunitiesFrameCommunitiesListListScrollFrameThumbTexture,
            CommunitiesFrameCommunitiesListListScrollFrameTop,
            CommunitiesFrameCommunitiesListListScrollFrameMiddle,
            CommunitiesFrameCommunitiesListListScrollFrameBottom
        }, true, true)
    end
end
