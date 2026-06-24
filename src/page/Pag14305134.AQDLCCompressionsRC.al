page 14305134 "AQDLC Compressions RC"
{
    ApplicationArea = All;
    Caption = 'Item Ledger Compressions RC';
    PageType = RoleCenter;

    layout
    {
        area(RoleCenter)
        {
            part(CompressionCues; "AQDLC Compression Cues")
            {
                Caption = 'Item Ledger Compressions';
            }
            part("My User Tasks"; "User Tasks Activities")
            {
                Caption = 'User Tasks Activities';
                Visible = false;
            }
            part("Power BI Embedded Report Part"; "Power BI Embedded Report Part")
            {
            }
        }
    }

    actions
    {
        area(Embedding)
        {
            action(CompressionSchedules)
            {
                RunObject = page "AQDLC ILE Compression Schedule";
                ToolTip = 'Executes the Compression Schedules action.';
                Caption = 'Compression Schedules';
            }
            action(ItemSelections)
            {
                RunObject = page "AQDLC Compression Item Selectn";
                ToolTip = 'Executes the ItemSelections action.';
                Caption = 'Compression Item Selections';
            }
            action(CompressionAnalysis)
            {
                Caption = 'Compression Analysis';
                RunObject = Page "AQDLC Compression Analysis Rs";
                ToolTip = 'Analyzes inventory data prior to compression and identifies potential data integrity issues that may affect compression results.';
            }
            action(CompressionRegisters)
            {
                RunObject = page "AQDLC ILE Compression Regs";
                ToolTip = 'Executes the Compression Registers action.';
                Caption = 'Compression Registers';
            }
            action(ValuationComparison)
            {
                RunObject = page "AQDLC Item Valuation Comparisn";
                ToolTip = 'Executes the Valuation Comparisons action.';
                Caption = 'Valuation Comparison';
            }
            action(PostedDocsCompLog)
            {
                ApplicationArea = All;
                Caption = 'Posted Documents Compression Logs';
                RunObject = Page "AQDLC Posted Docs Compress Log";
                ToolTip = 'Posted Documents Compression Results';
            }
            action(QuantityOnHand)
            {
                RunObject = page "AQDLC Quantity on Hand";
                ToolTip = 'Executes the Quantity On Hand action.';
                Caption = 'Quantity On Hand';
            }
            action(Customers)
            {
                RunObject = page "Customer List";
                ToolTip = 'Executes the Customers action.';
                Caption = 'Customers';
            }
            action(Items)
            {
                RunObject = page "Item List";
                ToolTip = 'Executes the Items action.';
                Caption = 'Items';
            }
            action(Resources)
            {
                RunObject = page "Resource List";
                ToolTip = 'Executes the Resources action.';
                Caption = 'Resources';
            }
            action(Locations)
            {
                RunObject = page "Location List";
                ToolTip = 'Executes the Location action.';
                Caption = 'Locations';
            }
            action("Sales Quotes")
            {
                ToolTip = 'Open Sales Quotes List';
                RunObject = page "Sales Quotes";
                Caption = 'Sales Quotes';
            }
            action("Sales Orders")
            {
                ToolTip = 'Open Sales Orders List';
                RunObject = page "Sales Order List";
                Caption = 'Sales Orders';
            }
            action("Sales Invoices")
            {
                ToolTip = 'Open Sales invoices List';
                RunObject = page "Sales Invoice List";
                Caption = 'Sales Invoices';
            }
            action("Sales Return Orders")
            {
                ToolTip = 'Open Sales Return Orders List';
                RunObject = page "Sales Return Order List";
                Caption = 'Sales Return Orders';
            }
            action("Sales Credit Memos")
            {
                ToolTip = 'Open Sales Credit Memos List';
                RunObject = page "Sales Credit Memos";
                Caption = 'Sales Credit Memos';
            }
            action("Service Orders")
            {
                ToolTip = 'Open Service Orders List';
                RunObject = page "Service Orders";
                Caption = 'Service Orders';
            }
            action("Service Invoices")
            {
                ToolTip = 'Open Service Invoices List';
                RunObject = page "Service Invoices";
                Caption = 'Service Invoices';
            }
            action("Service Credit Memos")
            {
                ToolTip = 'Open Service Credit Memos List';
                RunObject = page "Service Credit Memos";
                Caption = 'Service Credit Memos';
            }
        }
        area(sections)
        {
            group(ILECompressions)
            {
                Caption = 'Item Ledger Compressions';
                Image = ResourcePlanning;

                action(CompressionSchedules1)
                {
                    ApplicationArea = Basic, Suite;
                    RunObject = page "AQDLC ILE Compression Schedule";
                    ToolTip = 'Executes the Compression Schedules action.';
                    Caption = 'Compression Schedules';
                    Image = ListPage;
                }
                action(ItemSelections1)
                {
                    ApplicationArea = Basic, Suite;
                    RunObject = page "AQDLC Compression Item Selectn";
                    ToolTip = 'Executes the ItemSelections action.';
                    Caption = 'Compression Item Selections';
                    Image = ListPage;
                }

                action(CompressionAnalysis1)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Compression Analysis';
                    RunObject = Page "AQDLC Compression Analysis Rs";
                    ToolTip = 'Analyzes inventory data prior to compression and identifies potential data integrity issues that may affect compression results.';
                    Image = AnalysisView;
                }
                action(CompressionRegisters1)
                {
                    ApplicationArea = Basic, Suite;
                    RunObject = page "AQDLC ILE Compression Regs";
                    ToolTip = 'Executes the Compression Registers action.';
                    Caption = 'Compression Registers';
                    Image = ListPage;
                }
                action(ValuationComparison1)
                {
                    ApplicationArea = Basic, Suite;
                    RunObject = page "AQDLC Item Valuation Comparisn";
                    ToolTip = 'Executes the Valuation Comparisons action.';
                    Caption = 'Valuation Comparison';
                    Image = ListPage;
                }
                action(PostedDocsCompLog1)
                {
                    ApplicationArea = All;
                    Caption = 'Posted Documents Compression Logs';
                    Image = ListPage;
                    RunObject = Page "AQDLC Posted Docs Compress Log";
                    ToolTip = 'Posted Documents Compression Results';
                }
                action(QuantityOnHand1)
                {
                    ApplicationArea = Basic, Suite;
                    RunObject = page "AQDLC Quantity on Hand";
                    ToolTip = 'Executes the Quantity On Hand action.';
                    Caption = 'Quantity On Hand';
                    Image = ListPage;
                }
            }
            group(Action76)
            {
                Caption = 'Sales';
                ToolTip = 'Make quotes, orders, and credit memos to customers. Manage customers and view transaction history.';
                action(Action61)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Customers';
                    Image = Customer;
                    RunObject = Page "Customer List";
                    ToolTip = 'View or edit detailed information for the customers that you trade with. From each customer card, you can open related information, such as sales statistics and ongoing orders, and you can define special prices and line discounts that you grant if certain conditions are met.';
                }
                action("Sales Quotes1")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Sales Quotes';
                    RunObject = Page "Sales Quotes";
                    ToolTip = 'Make offers to customers to sell certain products on certain delivery and payment terms. While you negotiate with a customer, you can change and resend the sales quote as much as needed. When the customer accepts the offer, you convert the sales quote to a sales invoice or a sales order in which you process the sale.';
                }
                action("Sales Orders1")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Sales Orders';
                    RunObject = Page "Sales Order List";
                    ToolTip = 'Record your agreements with customers to sell certain products on certain delivery and payment terms. Sales orders, unlike sales invoices, allow you to ship partially, deliver directly from your vendor to your customer, initiate warehouse handling, and print various customer-facing documents. Sales invoicing is integrated in the sales order process.';
                }
                action("Sales Orders - Microsoft Dynamics 365 Sales")
                {
                    ApplicationArea = Suite;
                    Caption = 'Sales Orders - Microsoft Dynamics 365 Sales';
                    RunObject = Page "CRM Sales Order List";
                    ToolTip = 'View sales orders in Dynamics 365 Sales that are coupled with sales orders in Business Central.';
                }
                action("Blanket Sales Orders")
                {
                    ApplicationArea = Suite;
                    Caption = 'Blanket Sales Orders';
                    Image = Reminder;
                    RunObject = Page "Blanket Sales Orders";
                    ToolTip = 'Use blanket sales orders as a framework for a long-term agreement between you and your customers to sell large quantities that are to be delivered in several smaller shipments over a certain period of time. Blanket orders often cover only one item with predetermined delivery dates. The main reason for using a blanket order rather than a sales order is that quantities entered on a blanket order do not affect item availability and thus can be used as a worksheet for monitoring, forecasting, and planning purposes..';
                }
                action("Sales Invoices1")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Sales Invoices';
                    RunObject = Page "Sales Invoice List";
                    ToolTip = 'Register your sales to customers and invite them to pay according to the delivery and payment terms by sending them a sales invoice document. Posting a sales invoice registers shipment and records an open receivable entry on the customer''s account, which will be closed when payment is received. To manage the shipment process, use sales orders, in which sales invoicing is integrated.';
                }
                action("Sales Return Orders1")
                {
                    ApplicationArea = SalesReturnOrder;
                    Caption = 'Sales Return Orders';
                    RunObject = Page "Sales Return Order List";
                    ToolTip = 'Compensate your customers for incorrect or damaged items that you sent to them and received payment for. Sales return orders enable you to receive items from multiple sales documents with one sales return, automatically create related sales credit memos or other return-related documents, such as a replacement sales order, and support warehouse documents for the item handling. Note: If an erroneous sale has not been paid yet, you can simply cancel the posted sales invoice to automatically revert the financial transaction.';
                }
                action("Sales Credit Memos1")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Sales Credit Memos';
                    RunObject = Page "Sales Credit Memos";
                    ToolTip = 'Revert the financial transactions involved when your customers want to cancel a purchase or return incorrect or damaged items that you sent to them and received payment for. To include the correct information, you can create the sales credit memo from the related posted sales invoice or you can create a new sales credit memo with copied invoice information. If you need more control of the sales return process, such as warehouse documents for the physical handling, use sales return orders, in which sales credit memos are integrated. Note: If an erroneous sale has not been paid yet, you can simply cancel the posted sales invoice to automatically revert the financial transaction.';
                }
                action("Sales Journals")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Sales Journals';
                    RunObject = Page "General Journal Batches";
                    RunPageView = where("Template Type" = const(Sales),
                                        Recurring = const(false));
                    ToolTip = 'Post any sales-related transaction directly to a customer, bank, or general ledger account instead of using dedicated documents. You can post all types of financial sales transactions, including payments, refunds, and finance charge amounts. Note that you cannot post item quantities with a sales journal.';
                }
                action("Posted Sales Invoices")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Posted Sales Invoices';
                    RunObject = Page "Posted Sales Invoices";
                    ToolTip = 'Open the list of posted sales invoices.';
                }
                action("Posted Sales Credit Memos")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Posted Sales Credit Memos';
                    RunObject = Page "Posted Sales Credit Memos";
                    ToolTip = 'Open the list of posted sales credit memos.';
                }
                action("Posted Sales Return Receipts")
                {
                    ApplicationArea = SalesReturnOrder;
                    Caption = 'Posted Sales Return Receipts';
                    RunObject = Page "Posted Return Receipts";
                    ToolTip = 'Open the list of posted sales return receipts.';
                }
                action("Posted Sales Shipments")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Posted Sales Shipments';
                    Image = PostedShipment;
                    RunObject = Page "Posted Sales Shipments";
                    ToolTip = 'Open the list of posted sales shipments.';
                }
                action(Action68)
                {
                    ApplicationArea = Location;
                    Caption = 'Transfer Orders';
                    Image = FinChargeMemo;
                    RunObject = Page "Transfer Orders";
                    ToolTip = 'Move inventory items between company locations. With transfer orders, you ship the outbound transfer from one location and receive the inbound transfer at the other location. This allows you to manage the involved warehouse activities and provides more certainty that inventory quantities are updated correctly.';
                }
                action(Reminders)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Reminders';
                    RunObject = Page "Reminder List";
                    ToolTip = 'Remind customers about overdue amounts based on reminder terms and the related reminder levels. Each reminder level includes rules about when the reminder will be issued in relation to the invoice due date or the date of the previous reminder and whether interests are added. Reminders are integrated with finance charge memos, which are documents informing customers of interests or other money penalties for payment delays.';
                }
                action("Finance Charge Memos")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Finance Charge Memos';
                    RunObject = Page "Finance Charge Memo List";
                    ToolTip = 'Send finance charge memos to customers with delayed payments, typically following a reminder process. Finance charges are calculated automatically and added to the overdue amounts on the customer''s account according to the specified finance charge terms and penalty/interest amounts.';
                }
            }
            group(Action63)
            {
                Caption = 'Purchasing';
                ToolTip = 'View history for sales, shipments, and inventory.';
                action(Vendors)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Vendors';
                    Image = Vendor;
                    RunObject = Page "Vendor List";
                    ToolTip = 'View or edit detailed information for the vendors that you trade with. From each vendor card, you can open related information, such as purchase statistics and ongoing orders, and you can define special prices and line discounts that the vendor grants you if certain conditions are met.';
                }
                action("Purchase Quotes")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Purchase Quotes';
                    RunObject = Page "Purchase Quotes";
                    ToolTip = 'Create purchase quotes to represent your request for quotes from vendors. Quotes can be converted to purchase orders.';
                }
                action("Purchase Orders")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Purchase Orders';
                    RunObject = Page "Purchase Order List";
                    ToolTip = 'Create purchase orders to mirror sales documents that vendors send to you. This enables you to record the cost of purchases and to track accounts payable. Posting purchase orders dynamically updates inventory levels so that you can minimize inventory costs and provide better customer service. Purchase orders allow partial receipts, unlike with purchase invoices, and enable drop shipment directly from your vendor to your customer. Purchase orders can be created automatically from PDF or image files from your vendors by using the Incoming Documents feature.';
                }
                action("Blanket Purchase Orders")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Blanket Purchase Orders';
                    RunObject = Page "Blanket Purchase Orders";
                    ToolTip = 'Use blanket purchase orders as a framework for a long-term agreement between you and your vendors to buy large quantities that are to be delivered in several smaller shipments over a certain period of time. Blanket orders often cover only one item with predetermined delivery dates. The main reason for using a blanket order rather than a purchase order is that quantities entered on a blanket order do not affect item availability and thus can be used as a worksheet for monitoring, forecasting, and planning purposes.';
                }
                action("Purchase Invoices")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Purchase Invoices';
                    RunObject = Page "Purchase Invoices";
                    ToolTip = 'Create purchase invoices to mirror sales documents that vendors send to you. This enables you to record the cost of purchases and to track accounts payable. Posting purchase invoices dynamically updates inventory levels so that you can minimize inventory costs and provide better customer service. Purchase invoices can be created automatically from PDF or image files from your vendors by using the Incoming Documents feature.';
                }
                action("Purchase Return Orders")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Purchase Return Orders';
                    RunObject = Page "Purchase Return Order List";
                    ToolTip = 'Create purchase return orders to mirror sales return documents that vendors send to you for incorrect or damaged items that you have paid for and then returned to the vendor. Purchase return orders enable you to ship back items from multiple purchase documents with one purchase return and support warehouse documents for the item handling. Purchase return orders can be created automatically from PDF or image files from your vendors by using the Incoming Documents feature. Note: If you have not yet paid for an erroneous purchase, you can simply cancel the posted purchase invoice to automatically revert the financial transaction.';
                }
                action("Purchase Credit Memos")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Purchase Credit Memos';
                    RunObject = Page "Purchase Credit Memos";
                    ToolTip = 'Create purchase credit memos to mirror sales credit memos that vendors send to you for incorrect or damaged items that you have paid for and then returned to the vendor. If you need more control of the purchase return process, such as warehouse documents for the physical handling, use purchase return orders, in which purchase credit memos are integrated. Purchase credit memos can be created automatically from PDF or image files from your vendors by using the Incoming Documents feature. Note: If you have not yet paid for an erroneous purchase, you can simply cancel the posted purchase invoice to automatically revert the financial transaction.';
                }
                action(PurchaseJournals)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Purchase Journals';
                    RunObject = Page "General Journal Batches";
                    RunPageView = where("Template Type" = const(Purchases),
                                        Recurring = const(false));
                    ToolTip = 'Post any purchase-related transaction directly to a vendor, bank, or general ledger account instead of using dedicated documents. You can post all types of financial purchase transactions, including payments, refunds, and finance charge amounts. Note that you cannot post item quantities with a purchase journal.';
                }
                action("Posted Purchase Invoices")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Posted Purchase Invoices';
                    RunObject = Page "Posted Purchase Invoices";
                    ToolTip = 'Opens a list of posted purchase invoices.';
                }
                action("Posted Purchase Credit Memos")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Posted Purchase Credit Memos';
                    RunObject = Page "Posted Purchase Credit Memos";
                    ToolTip = 'Opens a list of posted purchase credit memos.';
                }
                action("Posted Purchase Return Shipments")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Posted Purchase Return Shipments';
                    RunObject = Page "Posted Return Shipments";
                    ToolTip = 'Opens a list of posted purchase return shipments.';
                }
                action("Posted Purchase Receipts")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Posted Purchase Receipts';
                    RunObject = Page "Posted Purchase Receipts";
                    ToolTip = 'Open the list of posted purchase receipts.';
                }
            }
            group(Action62)
            {
                Caption = 'Inventory';
                ToolTip = 'Manage physical or service-type items that you trade in by setting up item cards with rules for pricing, costing, planning, reservation, and tracking. Set up storage places or warehouses and how to transfer between such locations. Count, adjust, reclassify, or revalue inventory.';
                action(Action93)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Items';
                    Image = Item;
                    RunObject = Page "Item List";
                    ToolTip = 'View or edit detailed information for the products that you trade in. The item card can be of type Inventory or Service to specify if the item is a physical unit or a labor time unit. Here you also define if items in inventory or on incoming orders are automatically reserved for outbound documents and whether order tracking links are created between demand and supply to reflect planning actions.';
                }
                action(Action96)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Item Journals';
                    RunObject = Page "Item Journal Batches";
                    RunPageView = where("Template Type" = const(Item),
                                        Recurring = const(false));
                    ToolTip = 'Post item transactions directly to the item ledger to adjust inventory in connection with purchases, sales, and positive or negative adjustments without using documents. You can save sets of item journal lines as standard journals so that you can perform recurring postings quickly. A condensed version of the item journal function exists on item cards for quick adjustment of an items inventory quantity.';
                }
                action("Item Charges")
                {
                    ApplicationArea = Suite;
                    Caption = 'Item Charges';
                    RunObject = Page "Item Charges";
                    ToolTip = 'View or edit the codes for item charges that you can assign to purchase and sales transactions to include any added costs, such as freight, physical handling, and insurance that you incur when purchasing or selling items. This is important to ensure correct inventory valuation. For purchases, the landed cost of a purchased item consists of the vendor''s purchase price and all additional direct item charges that can be assigned to individual receipts or return shipments. For sales, knowing the cost of shipping sold items can be as vital to your company as knowing the landed cost of purchased items.';
                }
                action("Item Attributes")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Item Attributes';
                    RunObject = Page "Item Attributes";
                    ToolTip = 'Assign item attribute values to your items to enable rich searching and sorting options. When customers inquire about an item, either in correspondence or in an integrated web shop, they can then ask or search according to characteristics, such as height and model year. You can also assign item attributes to item categories, which then apply to the items that use the item categories in question.';
                }
                action("Item Tracking")
                {
                    ApplicationArea = ItemTracking;
                    Caption = 'Item Tracking';
                    RunObject = Page "Avail. - Item Tracking Lines";
                    ToolTip = 'Assign serial, lot and package numbers to any outbound or inbound document for quality assurance, recall actions, and to control expiration dates and warranties. Use the Item Tracing window to trace items with serial, lot or package numbers backwards and forward in their supply chain';
                }
                action("Item Reclassification Journals")
                {
                    ApplicationArea = Warehouse;
                    Caption = 'Item Reclassification Journals';
                    RunObject = Page "Item Journal Batches";
                    RunPageView = where("Template Type" = const(Transfer),
                                        Recurring = const(false));
                    ToolTip = 'Change information on item ledger entries, such as dimensions, location codes, bin codes, and serial, lot or package numbers.';
                }
                action("Phys. Inventory Journals")
                {
                    ApplicationArea = Warehouse;
                    Caption = 'Phys. Inventory Journals';
                    RunObject = Page "Item Journal Batches";
                    RunPageView = where("Template Type" = const("Phys. Inventory"),
                                        Recurring = const(false));
                    ToolTip = 'Select how you want to maintain an up-to-date record of your inventory at different locations.';
                }
                action("Assembly Orders")
                {
                    ApplicationArea = Assembly;
                    Caption = 'Assembly Orders';
                    RunObject = Page "Assembly Orders";
                    ToolTip = 'Combine components in simple processes without the need of manufacturing functionality. Sell assembled items by building the item to order or by picking from stock.';
                }
                action("Drop Shipments")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Drop Shipments';
                    RunObject = Page "Sales Lines";
                    RunPageView = where("Drop Shipment" = const(true));
                    ToolTip = 'Minimize delivery time and inventory cost by having items shipped from your vendor directly to your customer. This simply requires that you mark the sales order for drop shipment and then create a linked purchase order with the customer specified as the recipient. ';
                }
                action(Locations1)
                {
                    ApplicationArea = Location;
                    Caption = 'Locations';
                    RunObject = Page "Location List";
                    ToolTip = 'Manage the different places or warehouses where you receive, process, or ship inventory to increase customer service and keep inventory costs low.';
                }
            }
            group("Posted Documents")
            {
                Caption = 'Posted Documents';
                ToolTip = 'View the posting history for sales, shipments, and inventory.';
                action(Action32)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Posted Sales Invoices';
                    Image = PostedOrder;
                    RunObject = Page "Posted Sales Invoices";
                    ToolTip = 'Open the list of posted sales invoices.';
                }
                action(Action34)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Posted Sales Credit Memos';
                    Image = PostedOrder;
                    RunObject = Page "Posted Sales Credit Memos";
                    ToolTip = 'Open the list of posted sales credit memos.';
                }
                action("Posted Return Receipts")
                {
                    ApplicationArea = SalesReturnOrder;
                    Caption = 'Posted Return Receipts';
                    Image = PostedReturnReceipt;
                    RunObject = Page "Posted Return Receipts";
                    ToolTip = 'Open the list of posted return receipts.';
                }
                action(Action40)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Posted Sales Shipments';
                    Image = PostedShipment;
                    RunObject = Page "Posted Sales Shipments";
                    ToolTip = 'Open the list of posted sales shipments.';
                }
                action("Sales Quote Archive")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Sales Quote Archives';
                    RunObject = page "Sales Quote Archives";
                }
                action("Sales Order Archive")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Sales Order Archives';
                    RunObject = page "Sales Order Archives";
                }
                action("Sales Return Order Archives")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Sales Return Order Archives';
                    RunObject = page "Sales Return List Archive";
                }
                action("Blanket Sales Order Archives")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Blanket Sales Order Archives';
                    RunObject = page "Blanket Sales Order Archives";
                }
                action(Action54)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Posted Purchase Invoices';
                    RunObject = Page "Posted Purchase Invoices";
                    ToolTip = 'Open the list of posted purchase invoices.';
                }
                action(Action86)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Posted Purchase Credit Memos';
                    RunObject = Page "Posted Purchase Credit Memos";
                    ToolTip = 'Opens the list of posted purchase credit memos.';
                }
                action(Action87)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Posted Purchase Return Shipments';
                    RunObject = Page "Posted Return Shipments";
                    ToolTip = 'Opens the list of posted purchase return shipments.';
                }
                action(Action53)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Posted Purchase Receipts';
                    RunObject = Page "Posted Purchase Receipts";
                    ToolTip = 'Open the list of posted purchase receipts.';
                }
                action("Posted Transfer Shipments")
                {
                    ApplicationArea = Location;
                    Caption = 'Posted Transfer Shipments';
                    RunObject = Page "Posted Transfer Shipments";
                    ToolTip = 'Open the list of posted transfer shipments.';
                }
                action("Posted Transfer Receipts")
                {
                    ApplicationArea = Location;
                    Caption = 'Posted Transfer Receipts';
                    RunObject = Page "Posted Transfer Receipts";
                    ToolTip = 'Open the list of posted transfer receipts.';
                }
                action("Issued Reminders")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Issued Reminders';
                    RunObject = Page "Issued Reminder List";
                    ToolTip = 'Opens the list of issued reminders.';
                }
                action("Issued Finance Charge Memos")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Issued Finance Charge Memos';
                    RunObject = Page "Issued Fin. Charge Memo List";
                    ToolTip = 'Opens the list of issued finance charge memos.';
                }
            }
        }
        area(Creation)
        {
            action("&Adjust Cost - Item Entries")
            {
                ApplicationArea = All;
                Caption = 'Adjust Cost - Item Entries';
                Image = AdjustItemCost;
                RunObject = Report "Adjust Cost - Item Entries";
                ToolTip = 'Run Adjust Cost - Item Entries';
            }
            action("&Post Inventory Cost to G/L")
            {
                ApplicationArea = All;
                Caption = 'Post Inventory Cost to G/L';
                Image = PostDocument;
                RunObject = Report "Post Inventory Cost to G/L";
                ToolTip = 'Run Post Inventory Cost to G/L';
            }
            action("&Inventory Valuation")
            {
                ApplicationArea = All;
                Caption = 'Inventory Valuation Report';
                Image = PostDocument;
                RunObject = Report "Inventory Valuation";
                ToolTip = 'Run Inventory Valuation Report';
            }
            action(RunItemSelection)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Run Item Selection';
                Image = Report;
                RunObject = Report "AQDLC Compress Item Selection";
            }

            action(RunCompressionDataAnalysis)
            {
                ApplicationArea = All;
                Caption = 'Run Compression Data Analysis';
                Image = Process;
                RunObject = Report "AQDLC Compression Data Analys";
                ToolTip = 'Analyzes inventory data prior to compression and identifies potential data integrity issues that may affect compression results.';
            }
            action(RunILECompression)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Run Item Ledger Compression';
                Image = Report;
                RunObject = Report "AQDLC Date Compress Item Ledg";
            }
            action(RunPostedDocumentsCompression)
            {
                ApplicationArea = All;
                Caption = 'Run Posted Documents Compression';
                Image = Compress;
                RunObject = Report "AQDLC Posted Documents Compres";
                ToolTip = 'Date-Compresses Posted Documents';
            }
        }
        area(processing)
        {
            action("AQDLC ILE Compression Setup")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Acumens Item Ledger Compression Setup';
                Image = Setup;
                RunObject = Page "AQDLC ILE Compression Setup";
            }
            group(AcumensSetups)
            {
                Caption = 'Setups';
                action(CompressionSchedules2)
                {
                    ApplicationArea = Basic, Suite;
                    RunObject = page "AQDLC ILE Compression Schedule";
                    ToolTip = 'Executes the Compression Schedules action.';
                    Caption = 'Compression Schedules';
                    Image = ListPage;
                }
            }
            group(Tasks)
            {
                Caption = 'Tasks';
                action("Sales &Journal")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Sales &Journal';
                    Image = Journals;
                    RunObject = Page "Sales Journal";
                    ToolTip = 'Open a sales journal where you can batch post sales transactions to G/L, bank, customer, vendor and fixed assets accounts.';
                }
                action("Sales Price &Worksheet")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Price &Worksheet';
                    Image = PriceWorksheet;
                    RunPageView = where("Object Type" = const(Page), "Object ID" = const(7023)); // "Sales Price Worksheet";
                    RunObject = Page "Role Center Page Dispatcher";
                    ToolTip = 'Manage sales prices for individual customers, for a group of customers, for all customers, or for a campaign.';
                }
            }
            group(Action42)
            {
                Caption = 'Sales';
                action("&Prices")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = '&Prices';
                    Image = SalesPrices;
                    RunPageView = where("Object Type" = const(Page), "Object ID" = const(7002)); // "Sales Prices";
                    RunObject = Page "Role Center Page Dispatcher";
                    ToolTip = 'Set up different prices for items that you sell to the customer. An item price is automatically granted on invoice lines when the specified criteria are met, such as customer, quantity, or ending date.';
                }
                action("&Line Discounts")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = '&Line Discounts';
                    Image = SalesLineDisc;
                    RunPageView = where("Object Type" = const(Page), "Object ID" = const(7004)); // "Sales Line Discounts";
                    RunObject = Page "Role Center Page Dispatcher";
                    ToolTip = 'Set up different discounts for items that you sell to the customer. An item discount is automatically granted on invoice lines when the specified criteria are met, such as customer, quantity, or ending date.';
                }
            }
            group(Reports)
            {
                Caption = 'Reports';
                group(Customer)
                {
                    Caption = 'Customer';
                    Image = Customer;
                    action("Customer - &Order Summary")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Customer - &Order Summary';
                        Image = "Report";
                        RunObject = Report "Customer - Order Summary";
                        ToolTip = 'View the quantity not yet shipped for each customer in three periods of 30 days each, starting from a selected date. There are also columns with orders to be shipped before and after the three periods and a column with the total order detail for each customer. The report can be used to analyze a company''s expected sales volume.';
                    }
#if not CLEAN28
                    action("Customer - &Top 10 List")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Customer - &Top 10 List (Obsolete)';
                        Image = "Report";
                        RunObject = Report "Customer - Top 10 List";
                        ToolTip = 'View which customers purchase the most or owe the most in a selected period. Only customers that have either purchases during the period or a balance at the end of the period will be included.';
                        ObsoleteState = Pending;
                        ObsoleteReason = 'This report has been replaced by the report Customer - Top List (Excel). This report will be removed in a future release.';
                        ObsoleteTag = '28.0';
                    }
#endif
                }
                group(Action31)
                {
                    Caption = 'Sales';
                    Image = Sales;
                    action("List Price Sheet")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'List Price Sheet';
                        Image = "Report";
                        RunPageView = where("Object Type" = const(Report), "Object ID" = const(10148)); // "List Price Sheet"
                        RunObject = Page "Role Center Page Dispatcher";
                        ToolTip = 'View a list of your items and their prices, for example, to send to customers. You can create the list for specific customers, campaigns, currencies, or other criteria.';
                    }
                    action("Inventory - Sales &Back Orders")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Inventory - Sales &Back Orders';
                        Image = "Report";
                        RunObject = Report "Inventory - Sales Back Orders";
                        ToolTip = 'View a list with the order lines whose shipment date has been exceeded. The following information is shown for the individual orders for each item: number, customer name, customer''s telephone number, shipment date, order quantity and quantity on back order. The report also shows whether there are other items for the customer on back order.';
                    }
                }
            }
            group(History)
            {
                Caption = 'History';
                action("Navi&gate")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Find entries...';
                    Image = Navigate;
                    RunObject = Page Navigate;
                    ShortCutKey = 'Ctrl+Alt+Q';
                    ToolTip = 'Find entries and documents that exist for the document number and posting date on the selected document. (Formerly this action was named Navigate.)';
                }
            }
        }
    }
}